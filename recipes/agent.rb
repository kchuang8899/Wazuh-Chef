#
# Cookbook Name:: ossec
# Recipe:: agent_auth
#

# Delete older ossec installation coming with AMI
bash 'delete old ossec' do
  code <<-EOH
    rm -rf /var/ossec
    rm -f /etc/init.d/ossec
    EOH
  only_if "cat /var/ossec/etc/ossec-init.conf | grep 2.7"
end

package 'ossec' do
  package_name 'ossec-hids-agent'
end

dir = node['coupa-ossec']['dir']
agent_auth = node['coupa-ossec']['agent_auth']

args = "-m #{node['coupa-ossec']['agent_server_ip']} -p #{agent_auth['port']} -A #{agent_auth['name']}"

if agent_auth['ca'] && File.exist?(agent_auth['ca'])
  args << ' -v ' + agent_auth['ca']
end

if agent_auth['certificate'] && File.exist?(agent_auth['certificate'])
  args << ' -x ' + agent_auth['certificate']
end

if agent_auth['key'] && File.exist?(agent_auth['key'])
  args << ' -k ' + agent_auth['key']
end

execute "#{dir}/bin/agent-auth #{args}" do
  timeout 30
  ignore_failure true
  only_if { node['coupa-ossec']['agent_server_ip'] && !File.size?("#{dir}/etc/client.keys") }
end

include_recipe 'coupa-ossec::common'

file "/etc/logrotate.d/ossec" do
  action :delete
end

cookbook_file "#{node['coupa-ossec']['dir']}/etc/internal_options.conf" do
  source "var/ossec/etc/agent_internal_options.conf"
  owner 'root'
  group 'ossec'
  action :create
  notifies :restart, "service[ossec]", :delayed
end
