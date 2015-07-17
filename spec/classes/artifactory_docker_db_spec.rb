require 'spec_helper'

describe 'artifactory' do

  let(:facts) {{
    :concat_basedir             => '/var/lib/puppet/concat',
    # for docker
    :osfamily                   => 'RedHat',
    :operatingsystem            => 'CentOS',
    :operatingsystemrelease     => '7.1',
  }}

  let(:docker_mount_base)     { '/var/docker-artifactory' }

  let(:artifactory_home)      { '/var/opt/jfrog/artifactory' }
  let(:art_etc)               { "#{artifactory_home}/etc" }
  let(:art_backup)            { "#{artifactory_home}/backup" }
  let(:art_data)              { "#{artifactory_home}/data" }
  let(:storage_props)         { "#{art_etc}/storage.properties" }
  let(:storage_props_docker)  { "#{docker_mount_base}/etc/storage.properties" }


  # let's not test the _contents_ of storage.properties again, since this
  # is 99.99999% already done ;)

  context 'check default mounts with docker' do
    let(:params){{
      :install_type     => 'docker',
    }}
    it {
      should contain_docker__run('artifactory_service').
      with({
        :volumes => [
          "/var/docker-artifactory/data:#{artifactory_home}/data",
          "/var/docker-artifactory/logs:#{artifactory_home}/logs",
          "/var/docker-artifactory/backup:#{artifactory_home}/backup",
          "/var/docker-artifactory/etc:#{artifactory_home}/etc",
        ]
      })
    }
  end

  context 'check mounts with docker and database' do
    let(:params){{
      :install_type     => 'docker',
      :configure_db     => true,
      :db_type          => 'postgresql',
      :db_driver_jdbc   => '/my/jdbc/driver.jar',
    }}
    it {
      should contain_docker__run('artifactory_service').
      with({
        :volumes => [
          "/var/docker-artifactory/data:#{artifactory_home}/data",
          "/var/docker-artifactory/logs:#{artifactory_home}/logs",
          "/var/docker-artifactory/backup:#{artifactory_home}/backup",
          "/var/docker-artifactory/etc:#{artifactory_home}/etc",
          "/my/jdbc/driver.jar:#{artifactory_home}/tomcat/lib/driver.jar",
        ]
      })
    }
    it {
      should contain_exec('jdbc driver file not found: \'/my/jdbc/driver.jar\'').
      that_comes_before('Docker::Run[artifactory_service]')
    }
  end

  context 'check jdbc copying with docker' do
    let(:params){{
      :install_type     => 'docker',
      :configure_db     => true,
      :db_type          => 'mysql',
      :db_user_password => 'my_db_password',
    }}
    it {
      should contain_file(storage_props_docker).
      that_notifies('Docker::Run[artifactory_service]')
    }
  end


end
