# -*- encoding: utf-8 -*-
#
# Cookbook Name:: wazuh-elk
# Recipe:: elasticsearch
#
######################################################

include_recipe 'wazuh_elastic::elasticsearch_install'

service 'elasticsearch' do
  action [:enable, :start]
end
