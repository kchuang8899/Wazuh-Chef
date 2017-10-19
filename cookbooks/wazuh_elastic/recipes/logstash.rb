#
# Cookbook Name:: Elastic
# Recipe:: logstash

######################################################
include_recipe 'wazuh_elastic::logstash_install'

service 'logstash' do
  action [:enable, :start]
end
