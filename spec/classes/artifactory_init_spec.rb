require 'spec_helper'

describe 'artifactory', :type => :class do

  context 'init classes for package installation type' do
    let(:pre_condition) { 'class java {} ' }
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

    it { should create_class('artifactory') }
    it { should contain_class('artifactory::install') }
    it { should contain_class('artifactory::package::install') }
    it { should contain_class('artifactory::config') }
    it { should contain_class('artifactory::package::config') }
    it { should contain_class('artifactory::package::service') }
  end

  context 'init classes for docker installation type' do
    let(:facts) {{
      :concat_basedir             => '/var/lib/puppet/concat',
      :osfamily                   => 'RedHat',
      :operatingsystem            => 'CentOS',
      :operatingsystemrelease     => '7.1',
    }}
    let(:params) {{
      :install_type               => 'docker',
    }}

    it { should create_class('artifactory') }
    it { should contain_class('artifactory::install') }
    it { should contain_class('artifactory::docker::install') }
    it { should contain_class('artifactory::config') }
    it { should contain_class('artifactory::docker::config') }
    it { should contain_class('artifactory::docker::service') }
  end

  context 'init error: wrong installation type' do
    let(:pre_condition) { 'class java {} ' }
    let(:params) {{ :install_type => 'wohoo' }}
    it { expect { should compile }.to raise_error(/install_type must be/) }
  end

  context 'init error: ha_primary_node not set with ha_setup' do
    let(:pre_condition) { 'class java {} ' }
    let(:params) {{ :ha_setup => 'wohoo', :ha_security_token => '1234' }}
    it { expect { should compile }.to raise_error(/must set \$ha_primary_node/) }
  end

  context 'init error: ha_security_token not set with ha_setup' do
    let(:pre_condition) { 'class java {} ' }
    let(:params) {{ :ha_setup => 'wohoo', :ha_primary_node => false, }}
    it { expect { should compile }.to raise_error(/must set \$ha_security_token/) }
  end

  context 'init db error: wrong database type' do
    let(:pre_condition) { 'class java {} ' }
    let(:params) {{ :configure_db => true, :db_type => 'cocojambo', }}
    it { expect { should compile }.to raise_error(/Unsupported db type/) }
  end


end
