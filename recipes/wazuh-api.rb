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
  not_if "test -d #{Chef::Config[:file_cache_path]}/#{node['ossec']['api']['version']}.tar.gz"
end

bash "Install_RESful API" do
  code <<-EOH
    cd #{Chef::Config[:file_cache_path]} &&
    mkdir -p #{node['ossec']['dir']}/api &&  cp -r #{node['ossec']['api']['version']}/* #{node['ossec']['dir']}/api
    EOH
  not_if "test -d #{node['ossec']['dir']}/api"
end

bash "Install_npm_RESful API" do
  code <<-EOH
    cd #{node['ossec']['dir']}/api && npm install
    EOH
  not_if "test -d #{node['ossec']['dir']}/api/node_modules"
end

template 'wazuh-api init' do
  path '/etc/init.d/wazuh-api'
  source 'wazuh-api.service.erb'
  owner 'root'
  group 'root'
  mode 0755
end

cookbook_file "#{node['ossec']['dir']}/api/config.js" do
  source "var/ossec/api/config.js"
  owner 'root'
  group 'ossec'
  action :create
  notifies :restart, "service[wazuh-api]", :delayed
end

service 'wazuh-api' do
  supports restart: true
  action [:enable, :start]
  subscribes :restart, 'template[wazuh-api init]'
end
