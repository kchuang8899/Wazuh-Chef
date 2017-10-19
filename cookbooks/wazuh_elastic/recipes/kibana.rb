#
# Cookbook Name:: wazuh-elastic
# Recipe:: kibana_install

# Create user and group
#

include_recipe 'wazuh_elastic::kibana_install'

service 'kibana' do
  supports status: true, restart: false
  action [:enable, :start]
end
