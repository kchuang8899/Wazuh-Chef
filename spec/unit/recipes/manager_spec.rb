#
# Cookbook Name:: pm_wazuh_ossec
# Spec:: manager
#

require 'spec_helper'

describe 'pm_wazuh_ossec::manager' do
  cached(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

  before do
    allow(Chef::EncryptedDataBagItem).to receive(:load).with('wazuh_secrets', 'api').and_return(
      '{"htpasswd_user": "ossec","htpasswd_passcode": "ossec"}'
    )
  end

  it 'includes the pm_wazuh_ossec::manager recipe' do
    expect(chef_run).to include_recipe 'pm_wazuh_ossec::manager'
  end

  it 'creates a remote_file /tmp/ossec-wazuh-1.1.1.tar.gz' do
    expect(chef_run).to create_remote_file('/tmp/ossec-wazuh-1.1.1.tar.gz')
  end

  it 'creates a remote_file /tmp/ossec-wazuh-1.1.1/etc/preloaded-vars.conf' do
    expect(chef_run).to create_template('/tmp/ossec-wazuh-1.1.1/etc/preloaded-vars.conf')
  end

  it '/var/ossec/etc/internal_options.conf' do
    expect(chef_run).to create_template('/var/ossec/etc/internal_options.conf').with(
      user:   'root',
      group:  'ossec'
    )
  end

  it 'installs a package libssl-dev' do
    expect(chef_run).to install_package('libssl-dev')
    expect(chef_run).to_not install_package('not_libssl-dev')
  end

  it 'runs a bash script Creating ossec-authd key and cert' do
    expect(chef_run).to run_bash('Creating ossec-authd key and cert')
  end

  it 'runs a bash script Install nodejs' do
    expect(chef_run).to run_bash('Install nodejs')
  end

  it 'service restart ossec-authd' do
    expect(chef_run).to start_service('ossec-authd')
  end

  it 'packages to compile Wazuh-ossec Ubuntu' do
    expect(chef_run).to install_package(['gcc', 'make', 'curl'])
  end
end
