

case node['platform']
when 'debian', 'ubuntu'

  bash 'Install nodejs' do
    code <<-EOH
      cd /tmp &&
      curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
      EOH
    not_if { ::File.exist?('/etc/apt/sources.list.d/nodesource.list') }
  end

when 'redhat', 'centos', 'fedora'

  bash 'Install nodejs' do
    code <<-EOH
      cd /tmp &&
      curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
      EOH
    not_if { ::File.exist?('/etc/yum.repos.d/nodesource-el.repo') }
  end

end

package 'nodejs'

remote_file "/tmp/#{node['ossec']['api']['version']}.tar.gz" do
  source node['ossec']['api']['url']
end

bash 'extract_RESful API' do
  code <<-EOH
    cd /tmp &&
    tar -zxvf #{node['ossec']['api']['version']}.tar.gz
    EOH
  not_if { ::File.directory?("/tmp/#{node['ossec']['api']['name']}") }
end

bash 'Install_RESful API' do
  code <<-EOH
    cd /tmp &&
    mkdir -p #{node['ossec']['dir']}/api &&  cp -r #{node['ossec']['api']['name']}/* #{node['ossec']['dir']}/api
    EOH
  not_if { ::File.directory?("#{node['ossec']['dir']}/api") }
end

bash 'Install_npm_RESful API' do
  code <<-EOH
    cd #{node['ossec']['dir']}/api && npm install
    EOH
  not_if { ::File.directory?("#{node['ossec']['dir']}/api/node_modules") }
end

api_keys = Chef::EncryptedDataBagItem.load('wazuh_secrets', 'api')

file "#{node['ossec']['dir']}/api/ssl/htpasswd" do
  mode '0544'
  owner 'root'
  group 'root'
  content "#{api_keys['htpasswd_user']}:#{api_keys['htpasswd_passcode']}"
  action :create
  notifies :restart, 'service[wazuh-api]', :delayed
end

execute 'Wazuh API service' do
  command 'cd /var/ossec/api/scripts && sh install_daemon.sh'
end

service 'wazuh-api' do
  supports restart: true
  action [:enable, :start]
  subscribes :restart, 'template[wazuh-api init]'
end
