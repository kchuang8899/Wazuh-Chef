#
# Cookbook Name:: wazuh_ossec
# Recipe:: repository
#
# Copyright 2015, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when 'debian'
  package 'lsb-release'

  ohai 'reload lsb' do
    plugin 'lsb'
    # action :nothing
    subscribes :reload, 'package[lsb-release]', :immediately
  end

  apt_repository 'Wazuh' do
    uri 'http://ossec.wazuh.com/repos/apt/' + node['platform']
    key 'http://ossec.wazuh.com/repos/apt/conf/ossec-key.gpg.key'
    distribution lazy { node['lsb']['codename'] }
    components ['main']
  end
when 'rhel'
  yum_repository 'Wazuh' do
    description 'WAZUH OSSEC Repository - www.wazuh.com'
    baseurl 'http://ossec.wazuh.com/el/$releasever/$basearch'
    gpgkey 'http://ossec.wazuh.com/key/RPM-GPG-KEY-OSSEC'
    action :create
  end
end
