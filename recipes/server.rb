#
# Cookbook Name:: ossec
# Recipe:: server
#
#
# Delete older ossec installation coming with AMI
bash 'delete old ossec' do
  code <<-EOH
    rm -rf /var/ossec
    rm -f /etc/init.d/ossec
    EOH
  only_if "cat /var/ossec/etc/ossec-init.conf | grep 2.7"
end


# Install new ossec
package 'ossec-hids-wazuh' do
  package_name 'ossec-hids-wazuh'
  version node['coupa-ossec']['version']
end


include_recipe 'coupa-ossec::wazuh-api'



include_recipe 'coupa-ossec::aws-tools'

bash 'add default agent' do
  code <<-EOH
    echo "127.0.0.1,DEFAULT_LOCAL_AGENT" > #{node['coupa-ossec']['dir']}/default_local_agent
    cd #{node['coupa-ossec']['dir']} && #{node['coupa-ossec']['dir']}/bin/manage_agents -f default_local_agent
    EOH
    not_if "cat #{node['coupa-ossec']['dir']}/etc/client.keys"
    #not_if { ::File.exists?"/var/ossec/default_local_agent" }
end

include_recipe 'coupa-ossec::common'

authd = node['coupa-ossec']['authd']

template 'ossec-authd init' do
  path '/etc/init.d/ossec-authd'
  source 'ossec-authd.service.erb'
  owner 'root'
  group 'root'
  mode 0755
end

service 'ossec-authd' do
  supports restart: true
  action [:enable, :start]
  subscribes :restart, 'template[ossec-authd init]'
end

cookbook_file "/etc/logrotate.d/ossec-hids-wazuh" do
  source "etc/logrotate.d/alerts"
  action :create
end

cookbook_file "#{node['coupa-ossec']['dir']}/etc/internal_options.conf" do
  source "var/ossec/etc/manager_internal_options.conf"
  owner 'root'
  group 'ossec'
  action :create
  notifies :restart, "service[ossec]", :delayed
end

template "#{node['coupa-ossec']['dir']}/rules/local_rules.xml" do
  source "ossec_local_rules.xml.erb"
  owner 'root'
  group 'ossec'
  mode 00640
  notifies :restart, "service[ossec]", :delayed
end

#To allow cloudtrail-ossec logs withe ossec contrab
directory '/var/ossec' do
  owner 'ossec'
  group 'ossec'
  mode '0755'
  action :create
end

# Add DNS
include_recipe "coupa-base::dns"
