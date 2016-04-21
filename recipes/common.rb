#
# Cookbook Name:: ossec
# Recipe:: common
#

ruby_block 'ossec install_type' do
  block do
    if node.recipes.include?('coupa-ossec::default')
      type = 'local'
    else
      type = nil

      File.open('/var/ossec/etc/ossec-init.conf') do |file|
        file.each_line do |line|
          if line =~ /^TYPE="([^"]+)"/
            type = Regexp.last_match(1)
            break
          end
        end
      end
    end
    node.set['coupa-ossec']['install_type'] = type
  end
end

# Gyoku renders the XML.
chef_gem 'gyoku' do
  compile_time false if respond_to?(:compile_time)
end

file "#{node['coupa-ossec']['dir']}/etc/ossec.conf" do
  owner 'root'
  group 'ossec'
  mode 0440
  manage_symlink_source true
  notifies :restart, 'service[ossec]'
  content lazy {
    # Merge the "typed" attributes over the "all" attributes.
    all_conf = node['coupa-ossec']['conf']['all'].to_hash
    type_conf = node['coupa-ossec']['conf'][node['coupa-ossec']['install_type']].to_hash
    conf = Chef::Mixin::DeepMerge.deep_merge(type_conf, all_conf)
    Chef::OSSEC::Helpers.ossec_to_xml('ossec_config' => conf)
  }
end

file "#{node['coupa-ossec']['dir']}/etc/shared/agent.conf" do
  owner 'root'
  group 'ossec'
  mode 0440
  notifies :restart, 'service[ossec]'
  # Even if agent.cont is not appropriate for this kind of
  # installation, we need to create an empty file instead of deleting
  # for two reasons. Firstly, install_type is set at converge time
  # while action can't be lazy. Secondly, a subsequent package update
  # would just replace the file.
  action :create
  content lazy {
    if node['coupa-ossec']['install_type'] == 'manager'
      conf = node['coupa-ossec']['agent_conf'].to_a
      Chef::OSSEC::Helpers.ossec_to_xml('agent_config' => conf)
    else
      ''
    end
  }
end

# The RPM packages enable and start the service
# immediately after installation, which isn't helpful. An empty
# client.keys file will cause a server not to listen and an agent to
# abort immediately. Explicitly stopping the service here after
# installation allows Chef to start it when client.keys has content.
service 'stop ossec' do
  service_name 'ossec-hids'
  action :nothing
  %w( disable stop ).each do |action|
    subscribes action, 'package[ossec]', :immediately
  end
end

service 'ossec' do
  service_name 'ossec-hids'
  supports status: true, restart: true
  action [:enable, :start]
  not_if do
    (node['coupa-ossec']['install_type'] == 'agent' && node['coupa-ossec']['agent_server_ip'].nil?)
  end
end
