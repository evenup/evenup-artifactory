require 'spec_helper'

describe 'artifactory' do

  let(:facts) {{
    :concat_basedir             => '/var/lib/puppet/concat',
    # for docker
    :osfamily                   => 'RedHat',
    :operatingsystem            => 'CentOS',
    :operatingsystemrelease     => '7.1',
  }}

  let(:mount_base)            { '/var/artifactory' }

  let(:artifactory_home)      { '/var/opt/jfrog/artifactory' }
  let(:art_etc)               { "#{artifactory_home}/etc" }
  let(:art_backup)            { "#{artifactory_home}/backup" }
  let(:art_data)              { "#{artifactory_home}/data" }
  let(:storage_props)         { "#{art_etc}/storage.properties" }
  let(:storage_props_docker)  { "#{mount_base}/etc/storage.properties" }


  context 'license file with docker' do
    let(:params){{
      :install_type     => 'docker',
      :license_content  => 'yaahoo',
    }}
    it {
      should contain_file('/etc/artifactory/artifactory.lic').with_content('yaahoo').
      that_notifies('Docker::Run[artifactory_service]')
    }
  end

  context 'license file with package' do
    let(:pre_condition) { 'class java {} ' }
    let(:params){{
      :license_content  => 'yaahoo',
    }}
    it {
      should contain_file('/etc/artifactory/artifactory.lic').with_content('yaahoo').
      that_notifies('Service[artifactory]')
    }
  end

end
