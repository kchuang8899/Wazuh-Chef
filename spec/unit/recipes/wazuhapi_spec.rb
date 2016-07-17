#
# Cookbook Name:: pm_wazuh_ossec
# Spec:: wazuh_api
#

require 'spec_helper'

describe 'pm_wazuh_ossec::wazuh_api' do
  cached(:chef_run) { ChefSpec::ServerRunner.new.converge(described_recipe) }

  before do
    allow(Chef::EncryptedDataBagItem).to receive(:load).with('wazuh_secrets', 'api').and_return(
      '{"htpasswd_user": "ossec","htpasswd_passcode": "ossec"}'
    )
  end

  it 'includes the pm_wazuh_ossec::wazuh_api recipe' do
    expect(chef_run).to include_recipe 'pm_wazuh_ossec::wazuh_api'
  end

  it 'creates a remote_file /tmp/1.2.tar.gz' do
    expect(chef_run).to create_remote_file('/tmp/1.2.tar.gz')
  end

  it 'creates a file /var/ossec/api/ssl/htpasswd' do
    expect(chef_run).to create_file('/var/ossec/api/ssl/htpasswd').with(
      user:   'root',
      group:  'root'
    )
  end

  it 'service restart wazuh-api' do
    expect(chef_run).to start_service('wazuh-api')
  end

  it 'runs a bash script Install_npm_RESful API' do
    expect(chef_run).to run_bash('Install_npm_RESful API')
  end

  it 'runs a bash script Install_RESful API' do
    expect(chef_run).to run_bash('Install_RESful API')
  end

  it 'runs a bash script extract_RESful API' do
    expect(chef_run).to run_bash('extract_RESful API')
  end

  it 'runs a bash script Install nodejs' do
    expect(chef_run).to run_bash('Install nodejs')
  end

  it 'packages for RESTful API' do
    expect(chef_run).to install_package('nodejs')
  end
end
