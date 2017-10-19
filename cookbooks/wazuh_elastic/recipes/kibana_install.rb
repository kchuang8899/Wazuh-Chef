#
# Cookbook Name:: wazuh-elastic
# Recipe:: kibana_install

# Create user and group
#

package 'kibana' do
  version node['wazuh-elastic']['elasticsearch_version']
end

template 'kibana.yml' do
  path '/etc/kibana/kibana.yml'
  source 'kibana.yml.erb'
  owner 'root'
  group 'root'
  variables({
     :kibana_port => node['wazuh-elastic']['kibana_port'],
     :kibana_host => node['wazuh-elastic']['kibana_host'],
     :kibana_elasticsearch_server => node['wazuh-elastic']['kibana_elasticsearch_server']
  })
  mode 0755
end

ruby_block 'wait for elasticsearch' do
  block do
    loop { break if (TCPSocket.open("localhost",9200) rescue nil); puts "Waiting elasticsearch...."; sleep 1 }
  end
end

bash 'Install Wazuh-APP (can take a while)' do
  code <<-EOH
  /usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/wazuhapp/wazuhapp-2.1.1_5.6.3.zip
  EOH
  creates '/usr/share/kibana/plugins/wazuh/package.json'
  notifies :restart, 'service[kibana]', :delayed
end
