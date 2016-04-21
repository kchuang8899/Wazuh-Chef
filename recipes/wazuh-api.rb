package 'package npm for RESTful API' do
  package_name 'npm'
end

package 'package nodejs for RESTful API' do
  package_name 'nodejs'
end

remote_file "#{Chef::Config[:file_cache_path]}/#{node['coupa-ossec']['string']}" do
  source node['coupa-ossec']['url']
end

bash "extract_RESful API" do
  code <<-EOH
    cd #{Chef::Config[:file_cache_path]} &&
    tar -zxvf #{node['coupa-ossec']['string']}
    EOH
  not_if "test -d #{Chef::Config[:file_cache_path]}/wazuh-API-1.2"
end

bash "Install_RESful API" do
  code <<-EOH
    cd #{Chef::Config[:file_cache_path]} &&
    mkdir -p #{node['coupa-ossec']['dir']}/api &&  cp -r wazuh-API-*/* #{node['coupa-ossec']['dir']}/api
    EOH
  not_if "test -d #{node['coupa-ossec']['dir']}/api"
end

bash "Install_npm_RESful API" do
  code <<-EOH
    cd #{node['coupa-ossec']['dir']}/api && npm install
    EOH
  not_if "test -d #{node['coupa-ossec']['dir']}/api/node_modules"
end

template 'wazuh-api init' do
  path '/etc/init.d/wazuh-api'
  source 'wazuh-api.service.erb'
  owner 'root'
  group 'root'
  mode 0755
end

cookbook_file "#{node['coupa-ossec']['dir']}/api/config.js" do
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
