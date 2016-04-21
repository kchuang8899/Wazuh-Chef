#
# Cookbook Name:: coupa-ossec
# Attributes:: servers
#

default['coupa-ossec']['version'] = '1.1.0-3.el6'

default['coupa-ossec']['authd']['ip_address'] = false
default['coupa-ossec']['authd']['port'] = 1515

default['coupa-ossec']['authd']['ca'] = nil
default['coupa-ossec']['authd']['certificate'] = "#{node['coupa-ossec']['dir']}/etc/sslmanager.cert"
default['coupa-ossec']['authd']['key'] = "#{node['coupa-ossec']['dir']}/etc/sslmanager.key"

default['coupa-ossec']['agent_auth']['name'] = node['fqdn']
default['coupa-ossec']['agent_auth']['host'] = node['coupa-ossec']['agent_server_ip']
default['coupa-ossec']['agent_auth']['port'] = node['coupa-ossec']['authd']['port']

default['coupa-ossec']['agent_auth']['ca'] = nil
default['coupa-ossec']['agent_auth']['certificate'] = nil
default['coupa-ossec']['agent_auth']['key'] = nil
