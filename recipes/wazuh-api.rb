

case node['platform']
when 'debian', 'ubuntu'
  # do debian/ubuntu things
when 'redhat', 'centos'
     include_recipe 'yum-epel'
end

package 'packages for RESTful API' do
  package_name ['npm', 'nodejs']
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

template 'wazuh-api init' do
  path '/etc/init.d/wazuh-api'
  source 'wazuh-api.service.erb'
  owner 'root'
  group 'root'
  mode 0755
end

service 'wazuh-api' do
  supports restart: true
  action [:enable, :start]
  subscribes :restart, 'template[wazuh-api init]'
end
