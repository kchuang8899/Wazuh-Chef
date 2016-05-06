package 'packages for AWS Tools' do
  package_name ['openssl-devel']
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

bash 'install awscli' do
  code <<-EOH
    pip install awscli
  EOH
    not_if { ::File.exists?('/usr/bin/aws') }
end


cron 'noop' do
  minute '*/1'
  command "/usr/bin/flock -n /tmp/fcj.lockfile -c '/opt/coupa/bin/getawslog.py -b #{node['coupa-ossec']['aws']['backetname']} -d -j -D -l /var/ossec/logs/cloudtrail-ossec.log'"

  user 'ossec'
end
