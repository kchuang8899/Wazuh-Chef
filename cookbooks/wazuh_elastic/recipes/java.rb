#
# Cookbook Name:: wazuh-elastic
# Recipe:: java

# Create user and group
#
case node['platform']
when 'ubuntu'
  package 'lsb-release'

  ohai 'reload lsb' do
    plugin 'lsb'
    # action :nothing
    subscribes :reload, 'package[lsb-release]', :immediately
  end

  apt_repository 'java' do
    uri 'ppa:webupd8team/java'
    distribution node['lsb']['codename']
  end

 bash 'add not interactive installation to java-8' do
  code <<-EOH
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
    EOH
    not_if 'dpkg -s oracle-java8-installer'
  end

  apt_update 'update'

  package 'oracle-java8-installer'

when 'redhat', 'centos'

  remote_file '/tmp/jre-8-linux-x64.rpm' do
    source 'http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jre-8u151-linux-x64.rpm'
    headers ({ "Cookie" => "oraclelicense=ccept-securebackup-cookie" })
    checksum 'c8992e387f56a5fcd46a37640149a7e3c31c97dc70358a3c227874fd01828b85'
    not_if 'rpm -qa | grep jre1.8-1.8.0_151-fcs.x86_64'
    notifies :install, 'package[jre-8-linux-x64.rpm]', :immediately
  end

  package 'jre-8-linux-x64.rpm' do
    source '/tmp/jre-8-linux-x64.rpm'
    action :nothing
  end

end
