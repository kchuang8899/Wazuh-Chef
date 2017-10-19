default['wazuh-elastic']['elasticsearch_version'] = '5.6.3-1'
default['wazuh-elastic']['elasticsearch_cluster_name'] = 'wazuh'
default['wazuh-elastic']['elasticsearch_node_name'] = 'elk.wazuh-test.com'
default['wazuh-elastic']['elasticsearch_port'] = 9200

default['wazuh-elastic']['kibana_host'] = '0.0.0.0'
default['wazuh-elastic']['kibana_port'] = '5601'
default['wazuh-elastic']['kibana_elasticsearch_server'] = 'http://127.0.0.1:9200'

default['wazuh-elastic']['ossec_api_addres'] = 'https://172.16.10.10:55000'
