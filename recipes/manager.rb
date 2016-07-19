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
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform']
when 'debian', 'ubuntu'
  include_recipe 'apt::default'
end

include_recipe 'wazuh_ossec::install_manager'

include_recipe 'wazuh_ossec::common'

include_recipe 'wazuh_ossec::wazuh_api'

bash 'Creating ossec-authd key and cert' do
  code <<-EOH
    openssl genrsa -out #{node['ossec']['dir']}/etc/sslmanager.key 4096 &&
    openssl req -new -x509 -key #{node['ossec']['dir']}/etc/sslmanager.key\
   -out #{node['ossec']['dir']}/etc/sslmanager.cert -days 3650\
   -subj /CN=fqdn/
    EOH
  not_if { ::File.exist?("#{node['ossec']['dir']}/etc/sslmanager.cert") }
end

authd = node['ossec']['authd']

if node['init_package'] == 'systemd'
  template 'ossec-authd init' do
    path '/lib/systemd/system/ossec-authd.service'
    source 'ossec-authd.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables authd
  end

  execute 'systemctl daemon-reload' do
    action :nothing
    subscribes :run, 'template[ossec-authd init]', :immediately
  end
elsif node['init_package'] == 'init'
  template 'ossec-authd init' do
    path '/etc/init.d/ossec-authd'
    source 'ossec-authd-init.service.erb'
    owner 'root'
    group 'root'
    mode '0755'
  end
end

service 'ossec-authd' do
  supports restart: true
  action [:enable, :start]
  subscribes :restart, 'template[ossec-authd init]'
end

template "#{node['ossec']['dir']}/etc/internal_options.conf" do
  source 'var/ossec/etc/manager_internal_options.conf'
  owner 'root'
  group 'ossec'
  action :create
  notifies :restart, 'service[ossec]', :delayed
end

template "#{node['ossec']['dir']}/rules/local_rules.xml" do
  source 'ossec_local_rules.xml.erb'
  owner 'root'
  group 'ossec'
  mode '0640'
  notifies :restart, 'service[ossec]', :delayed
end
