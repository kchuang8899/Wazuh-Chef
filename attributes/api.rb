# API
default['ossec']['api']['version'] = "1.2"
default['ossec']['api']['name'] = "wazuh-API-#{node['ossec']['api']['version']}"
default['ossec']['api']['url'] = "https://github.com/wazuh/wazuh-API/archive/v#{node['ossec']['api']['version']}.tar.gz"
