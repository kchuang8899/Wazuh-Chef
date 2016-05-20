default['ossec']['manager']['version'] = "1.1.1"
default['ossec']['manager']['name'] = "ossec-wazuh-#{node['ossec']['manager']['version']}"
default['ossec']['manager']['url'] = "https://github.com/wazuh/ossec-wazuh/archive/v#{node['ossec']['manager']['version']}.tar.gz"
