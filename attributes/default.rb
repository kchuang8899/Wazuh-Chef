#
# Cookbook Name:: ossec
# Attributes:: default
#
# Copyright 2010-2015, Chef Software, Inc.
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
# general settings
default['ossec']['dir']             = '/var/ossec'
default['ossec']['server_role']     = 'ossec_server'
default['ossec']['server_env']      = nil
default['ossec']['agent_server_ip'] = nil
# The following attributes are mapped to XML for ossec.conf using
# Gyoku. See the README for details on how this works.

default['ossec']['conf']['all']['syscheck']['frequency'] = 21_600
default['ossec']['conf']['all']['rootcheck']['disabled'] = false
default['ossec']['conf']['all']['rootcheck']['rootkit_files'] = "#{node['ossec']['dir']}/etc/shared/rootkit_files.txt"
default['ossec']['conf']['all']['rootcheck']['rootkit_trojans'] = "#{node['ossec']['dir']}/etc/shared/rootkit_trojans.txt"

%w( local server ).each do |type|
 default['ossec']['conf'][type]['global']['jsonout_output'] = true
  default['ossec']['conf'][type]['global']['email_notification'] = false
  default['ossec']['conf'][type]['global']['email_from'] = "ossec@ossec.com"
  default['ossec']['conf'][type]['global']['email_to'] = "ossec@ossec.com"
  default['ossec']['conf'][type]['global']['smtp_server'] = "aspmx.l.google.com"
  default['ossec']['conf'][type]['global']['white_list'] = ['127.0.0.1','^localhost.localdomain$','192.168.0.0/24']

  default['ossec']['conf'][type]['alerts']['email_alert_level'] = 7
  default['ossec']['conf'][type]['alerts']['log_alert_level'] = 1
  default['ossec']['conf'][type]['rules']['decoder_dir'] = ['etc/ossec_decoders', 'etc/wazuh_decoders']
  default['ossec']['conf'][type]['rules']['include'] = [
  'rules_config.xml',
  'pam_rules.xml',
  'sshd_rules.xml',
  'telnetd_rules.xml',
  'syslog_rules.xml',
  'arpwatch_rules.xml',
  'symantec-av_rules.xml',
  'symantec-ws_rules.xml',
  'pix_rules.xml',
  'named_rules.xml',
  'smbd_rules.xml',
  'vsftpd_rules.xml',
  'pure-ftpd_rules.xml',
  'proftpd_rules.xml',
  'ms_ftpd_rules.xml',
  'ftpd_rules.xml',
  'hordeimp_rules.xml',
  'roundcube_rules.xml',
  'wordpress_rules.xml',
  'cimserver_rules.xml',
  'vpopmail_rules.xml',
  'vmpop3d_rules.xml',
  'courier_rules.xml',
  'web_rules.xml',
  'web_appsec_rules.xml',
  'apache_rules.xml',
  'nginx_rules.xml',
  'php_rules.xml',
  'mysql_rules.xml',
  'postgresql_rules.xml',
  'ids_rules.xml',
  'squid_rules.xml',
  'firewall_rules.xml',
  'apparmor_rules.xml',
  'cisco-ios_rules.xml',
  'netscreenfw_rules.xml',
  'sonicwall_rules.xml',
  'postfix_rules.xml',
  'sendmail_rules.xml',
  'imapd_rules.xml',
  'mailscanner_rules.xml',
  'dovecot_rules.xml',
  'ms-exchange_rules.xml',
  'racoon_rules.xml',
  'vpn_concentrator_rules.xml',
  'spamd_rules.xml',
  'msauth_rules.xml',
  'mcafee_av_rules.xml',
  'trend-osce_rules.xml',
  'ms-se_rules.xml',
  'zeus_rules.xml',
  'solaris_bsm_rules.xml',
  'vmware_rules.xml',
  'ms_dhcp_rules.xml',
  'asterisk_rules.xml',
  'ossec_rules.xml',
  'attack_rules.xml',
  'openbsd_rules.xml',
  'clam_av_rules.xml',
  'dropbear_rules.xml',
  'unbound_rules.xml',
  'sysmon_rules.xml',
  'auditd_rules.xml',
  'usb_rules.xml',
  'amazon_rules.xml',
  'amazon-iam_rules.xml',
  'amazon-ec2_rules.xml',
  'local_rules.xml'
]



  default['ossec']['conf'][type]['syscheck']['frequency'] = 7200
  default['ossec']['conf'][type]['syscheck']['nodiff'] = ['/etc/ssl/private.key']
  default['ossec']['conf'][type]['remote']['connection'] = ['secure']


end

default['ossec']['conf']['all']['command'] = [
  {
    'name' => 'host-deny',
    'executable' => 'host-deny.sh',
    'expect' => 'srcip',
    'timeout_allowed' => 'yes'
  },
 {
    'content!' => {
      'name' => 'firewall-drop',
      'executable' => 'firewall-drop.sh',
      'expect' => 'srcip',
      'timeout_allowed' => 'yes'
   }
  },
 {
    'content!' => {
      'name' => 'disable-account',
      'executable' => 'disable-account.sh',
      'expect' => 'user',
      'timeout_allowed' => 'yes'
   }
  },
 {
    'content!' => {
      'name' => 'restart-ossec',
      'executable' => 'restart-ossec.sh',
      'expect' => ''
   }
  },
{
    'content!' => {
      'name' => 'route-null',
      'executable' => 'disable-account.sh',
      'expect' => 'srcip',
      'timeout_allowed' => 'yes'
   }
  }
]

default['ossec']['conf']['all']['active-response']['disabled'] = false
default['ossec']['conf']['all']['active-response']['command'] = ['host-deny']
default['ossec']['conf']['all']['active-response']['location'] = ['local']
default['ossec']['conf']['all']['active-response']['level'] = ['6']
default['ossec']['conf']['all']['active-response']['timeout'] = ['1800']

default['ossec']['conf']['all']['syscheck']['directories'] = [
  { '@check_all' => true, 'content!' => '/etc,/usr/bin,/usr/sbin' },
  { '@check_all' => true, 'content!' => '/bin,/sbin' }
  ]
default['ossec']['conf']['all']['syscheck']['auto_ignore'] = false
default['ossec']['conf']['all']['syscheck']['ignore'] = [
  '/etc/mtab',
  '/etc/mnttab',
  '/etc/hosts.deny',
  '/etc/mail/statistics',
  '/etc/random-seed',
  '/etc/adjtime',
  '/etc/httpd/logs',
  '/etc/utmpx',
  '/etc/wtmpx',
  '/etc/cups/certs',
  '/etc/dumpdates',
  '/etc/svc/volatile'
  ]
default['ossec']['conf']['all']['rootcheck']['disabled'] = false
default['ossec']['conf']['all']['rootcheck']['rootkit_files'] = "#{node['ossec']['dir']}/etc/shared/rootkit_files.txt"
default['ossec']['conf']['all']['rootcheck']['rootkit_trojans'] = "#{node['ossec']['dir']}/etc/shared/rootkit_trojans.txt"
default['ossec']['conf']['all']['rootcheck']['system_audit'] = [
  '/var/ossec/etc/shared/system_audit_rcl.txt',
  '/var/ossec/etc/shared/cis_rhel_linux_rcl.txt',
  '/var/ossec/etc/shared/cis_rhel6_linux_rcl.txt'
  ]

default['ossec']['conf']['all']['localfile'] = [
  {
    'log_format' => 'syslog',
    'location' => '/var/log/messages'
  },
 {
    'content!' => {
      'log_format' => 'syslog',
      'location' => '/var/log/secure'
    }
  },
 {
    'content!' => {
      'log_format' => 'command',
      'command' => 'df -h'
    }
  },
 {
    'content!' => {
      'log_format' => 'full_command',
      'command' => 'netstat -tan |grep LISTEN |grep -v 127.0.0.1 | sort'
    }
  },
 {
    'content!' => {
      'log_format' => 'full_command',
      'command' => 'last -n 5'
    }
  },
  {
    'content!' => {
      'log_format' => 'syslog',
      'location' => '/var/log/authlog'
    }
  },
  {
    'content!' => {
      'log_format' => 'syslog',
      'location' => '/var/log/xferlog'
    }
  },
  {
    'content!' => {
      'log_format' => 'syslog',
      'location' => '/var/log/maillog'
    }
  },
  {
    'content!' => {
      'log_format' => 'syslog',
      'location' => '/var/ossec/logs/cloudtrail-ossec.log'
    }
  },
  {
    'content!' => {
      'log_format' => 'apache',
      'location' => '/var/www/logs/access_log'
    }
  },
  {
    'content!' => {
      'log_format' => 'apache',
      'location' => '/var/www/logs/error_log'
    }
  }
]

default['ossec']['conf']['server']['remote']['connection'] = 'secure'
default['ossec']['conf']['agent']['client']['server-ip'] = node['ossec']['agent_server_ip']

# agent.conf is also populated with Gyoku but in a slightly different
# way. We leave this blank by default because Chef is better at
# distributing agent configuration than OSSEC is.
default['ossec']['agent_conf'] = [
  {
        'syscheck' => { 'frequency' => 7200 },
        'rootcheck' => { 'disabled' => true }
      },
      {
        '@os' => 'Windows',
        'content!' => {
          'syscheck' => { 'frequency' => 7200 }
        }
      }
]
