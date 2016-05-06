name             'ossec-authd'
maintainer       'Wazuh Inc.'
maintainer_email 'jose@wazuh.com'
license          'Apache 2.0'
description      'Installs and onfigures ossec'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.5'

%w( apt yum-epel ).each do |pkg|
  depends pkg
end

%w( debian ubuntu redhat centos fedora ).each do |os|
  supports os
end

