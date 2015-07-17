require 'spec_helper'

describe 'artifactory' do

  let(:facts) {{
    :concat_basedir => '/var/lib/puppet/concat',
  }}

  let(:pre_condition) { 'class java{}' }

  let(:docker_mount_base)     { '/var/docker-artifactory' }

  let(:artifactory_home)      { '/var/opt/jfrog/artifactory' }
  let(:art_etc)               { "#{artifactory_home}/etc" }
  let(:art_backup)            { "#{artifactory_home}/backup" }
  let(:art_data)              { "#{artifactory_home}/data" }
  let(:art_tomcat_lib)        { "#{artifactory_home}/tomcat/lib" }
  let(:storage_props)         { "#{art_etc}/storage.properties" }
  let(:storage_props_docker)  { "#{docker_mount_base}/storage.properties" }


  context 'postgresql with package install' do
    let(:params){{
      :configure_db     => true,
      :db_type          => 'postgresql',
      :db_name          => 'my_db_name',
      :db_user          => 'my_db_user',
      :db_host          => 'lohcahlhost',
      :db_port          => '1111',
      :db_user_password => 'my_db_password',
    }}
    it {
      should contain_file("#{storage_props}").
      that_notifies('Service[artifactory]')
    }
    it {
      should contain_file("#{storage_props}").
      with_content(/type=postgresql/)
    }
    it {
      should contain_file("#{storage_props}").
      with_content(/username=my_db_user/)
    }
    it {
      should contain_file("#{storage_props}").
      with_content(/password=my_db_password/)
    }
    it {
      should contain_file("#{storage_props}").
      with_content(/driver=org.postgresql.Driver/)
    }
    it {
      should contain_file("#{storage_props}").
      with_content(/url=jdbc:postgresql:\/\/lohcahlhost:1111\/my_db_name/)
    }
  end

  context 'postgresql default values with package install' do
    let(:params){{
      :configure_db     => true,
      :db_type          => 'postgresql',
    }}
    it {
      should contain_file("#{storage_props}").
      with_content(/url=jdbc:postgresql:\/\/localhost:5432\/artifactory/)
    }
  end


  context 'with db_driver_jdbc set in package installation' do
    let(:params){{
      :configure_db     => true,
      :db_type          => 'mysql',
      :db_user_password => 'my_db_password',
      :db_driver_jdbc   => '/opt/driver.jar',
    }}
    it {
      should contain_exec('jdbc driver file not found: \'/opt/driver.jar\'')
      should contain_exec('copy jdbc driver file').
      that_requires("Exec[jdbc driver file not found: \'/opt/driver.jar\']").
      that_notifies('Service[artifactory]').
      with({
        :command => "cp '/opt/driver.jar' '#{art_tomcat_lib}'",
      })
    }
  end


end
