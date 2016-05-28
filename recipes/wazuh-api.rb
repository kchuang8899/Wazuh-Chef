
bash "Install nodejs " do
  code <<-EOH
    cd #{Chef::Config[:file_cache_path]} &&
    curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
    EOH
  not_if do ::File.exists?('/etc/apt/sources.list.d/nodesource.list') end
end

package 'packages for RESTful API' do
   package_name ['nodejs']
end

remote_file "#{Chef::Config[:file_cache_path]}/#{node['ossec']['api']['version']}.tar.gz" do
  source node['ossec']['api']['url']
end

bash "extract_RESful API" do
  code <<-EOH
    cd #{Chef::Config[:file_cache_path]} &&
    tar -zxvf #{node['ossec']['api']['version']}.tar.gz
    EOH
  not_if "test -d #{Chef::Config[:file_cache_path]}/#{node['ossec']['api']['name']}"
end

bash "Install_RESful API" do
  code <<-EOH
    cd #{Chef::Config[:file_cache_path]} &&
    mkdir -p #{node['ossec']['dir']}/api &&  cp -r #{node['ossec']['api']['name']}/* #{node['ossec']['dir']}/api
    EOH
  not_if "test -d #{node['ossec']['dir']}/api"
end

bash "Install_npm_RESful API" do
  code <<-EOH
    cd #{node['ossec']['dir']}/api && npm install
    EOH
  not_if "test -d #{node['ossec']['dir']}/api/node_modules"
end

api_keys =  Chef::EncryptedDataBagItem.load("passwords", "api")


file "#{node['ossec']['dir']}/api/ssl/htpasswd" do
  mode 0544
  owner "root"
  group "root"
  content "#{api_keys['htpasswd_user']}:#{api_keys['htpasswd_passcode']}"
  action :create
  notifies :restart, "service[wazuh-api]", :delayed
end


if node['init_package'] == 'systemd'
  template 'wazuh-api init' do
    path '/lib/systemd/system/wazuh-api.service'
    source 'wazuh-api.service.erb'
    owner 'root'
    group 'root'
    mode 0644
  end

  execute 'systemctl daemon-reload' do
    action :nothing
    subscribes :run, 'template[wazuh-api init]', :immediately
  end
else if node['init_package'] == 'init'
       template 'wazuh-api init' do
       path '/etc/init.d/wazuh-api'
       source 'wazuh-api-init.service.erb'
       owner 'root'
       group 'root'
       mode 0755
     end
    end
end

service 'wazuh-api' do
  supports restart: true
  action [:enable, :start]
  subscribes :restart, 'template[wazuh-api init]'
end
