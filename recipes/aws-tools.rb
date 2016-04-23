package 'packages for AWS Tools' do
  package_name 'openssl-devel'
end

cookbook_file "#{Chef::Config[:file_cache_path]}/get-pip.py" do
  source 'get-pip.py'
  mode "0644"
  not_if { ::File.exists?('/usr/bin/pip') }
end

execute "install-pip" do
  cwd Chef::Config[:file_cache_path]
  command <<-EOF
  #{node['coupa-ossec']['python']} get-pip.py
  EOF
  not_if { ::File.exists?('/usr/bin/pip') }
end


bash 'installing boto' do
  code <<-EOH
    pip install boto
  EOH
  not_if { ::File.exists?('/usr/lib/python2.6/site-packages/boto') }
end

# Use data bag viewer to grab credentials

logstash_aws_keys = encrypted_data_bag_item("aws_#{ownerid}", 'ec2cloudtrail_logstash') || \
                    fail("Data bag aws_#{ownerid} / ec2cloudtrail_logstash must exist")


# Add the credentials to boto configuration
file "/etc/boto.cfg" do
  mode 0544
  owner "root"
  group "root"
  content "[Credentials]\naws_access_key_id = #{logstash_aws_keys['access_key_id']}\naws_secret_access_key = #{logstash_aws_keys['secret_access_key']}\n"
end


cookbook_file "/opt/coupa/bin/getawslog.py" do
  source "opt/coupa/bin/getawslog.py"
  owner 'ossec'
  group 'root'
  mode 0744
  action :create
end

file '/var/ossec/logs/cloudtrail-ossec.log' do
  mode '0744'
  owner 'ossec'
  group 'ossec'
  not_if { ::File.exists?('/var/ossec/logs/cloudtrail-ossec.log') }
end


cron 'GetAWSlog' do
  minute '*/7'
  mailto 'jose@wazuh.com'
  command "/usr/bin/flock -n /tmp/fcj.lockfile -c '/opt/coupa/bin/getawslog.py -b #{node['coupa-ossec']['aws']['backetname']} -d -j -D -l /var/ossec/logs/cloudtrail-ossec.log'"
  user 'ossec'
  only_if {::File.exist?('/var/ossec/logs/cloudtrail-ossec.log')}
end

cookbook_file "/etc/logrotate.d/cloudtrail-ossec" do
  source "etc/logrotate.d/cloudtrail-ossec"
  action :create
end
