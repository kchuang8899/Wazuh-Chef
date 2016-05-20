#
# Cookbook Name:: ossec
# Recipe:: authd
#
# Copyright 2015, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'packages to compile Wazuh-ossec' do
  package_name ['gcc', 'make']
end

remote_file "#{Chef::Config[:file_cache_path]}/#{node['ossec']['manager']['name']}.tar.gz" do
  source node['ossec']['manager']['url']
end

package 'openssl-devel' do
  package_name value_for_platform_family('debian' => 'libssl-dev', 'default' => 'openssl-devel.x86_64')
end

bash "Install Wazuh-Ossec" do
  code <<-EOH
    cd #{Chef::Config[:file_cache_path]} && tar xvfz #{node['ossec']['manager']['name']}.tar.gz
    EOH
     not_if "test -d #{Chef::Config[:file_cache_path]}/#{node['ossec']['manager']['name']}"
end

template "#{Chef::Config[:file_cache_path]}/#{node['ossec']['manager']['name']}/etc/preloaded-vars.conf" do
  source "ossec_preloaded_vars.conf.erb"
  mode 00644
  variables({
    :user_install_type => 'server',
    :user_dir => node['ossec']['dir'],
  })
  notifies :run, "execute[install_ossec]", :immediately
end

execute "install_ossec" do
  command "#{Chef::Config[:file_cache_path]}/#{node['ossec']['manager']['name']}/install.sh"
  action :nothing
end

include_recipe 'wazuh-ossec::common'

include_recipe 'wazuh-ossec::wazuh-api'

authd = node['ossec']['authd']

#if node['init_package'] == 'systemd'
#  template 'ossec-authd init' do
#    path '/lib/systemd/system/ossec-authd.service'
#    source 'ossec-authd.service.erb'
#    owner 'root'
#    group 'root'
#    mode 0644
#    variables authd
#  end

 # execute 'systemctl daemon-reload' do
#    action :nothing
#    subscribes :run, 'template[ossec-authd init]', :immediately
#  end
#end

#service 'ossec-authd' do
#  supports restart: true
#  action [:enable, :start]
#  subscribes :restart, 'template[ossec-authd init]'
#
#  only_if do
#    File.exist?(authd['certificate']) && File.exist?(authd['key']) &&
#      (authd['ca'].nil? || File.exist?(authd['ca']))
#  end
#end
