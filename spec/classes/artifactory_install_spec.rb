require 'spec_helper'

describe 'artifactory' do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
  let(:pre_condition) { 'class java {} ' }

  context 'install' do
    context 'default' do

      it { should contain_user('artifactory') }
      it { should contain_group('artifactory') }
      it { should contain_package('artifactory').with(:ensure => 'latest') }
      it { should_not contain_file('/var/opt/jfrog/artifactory/data') }
    end

    context 'setting package parameters' do
      let(:params) { {
        :package_provider => 'rpm',
        :package_source => '/tmp/artifactory.rpm'
      } }

      it { should contain_package('artifactory').with(:provider => 'rpm', :source => '/tmp/artifactory.rpm') }
    end

    context 'custom data dir' do
      let(:params) { { :data_path => '/data/artifactory' } }

      it { should contain_file('/data/artifactory').with(:ensure => 'directory') }
      it { should contain_file('/var/opt/jfrog/artifactory/data').with(:ensure => 'link', :target => '/data/artifactory') }
    end

    context 'with backup path' do
      let(:params) { { :backup_path => '/backups/artifactory' } }

      it { should contain_file('/backups/artifactory').with(:ensure => 'directory') }
    end
  end

end
