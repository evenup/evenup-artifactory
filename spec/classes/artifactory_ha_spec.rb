require 'spec_helper'

describe 'artifactory' do

  let(:basefacts) {{
    :concat_basedir             => '/var/lib/puppet/concat',
    :hostname                   => 'testhost',
    :fqdn                       => 'testhost.test.com',
    :ipaddress                  => '1.2.3.4',
    # for docker, if needed
    :osfamily                   => 'RedHat',
    :operatingsystem            => 'CentOS',
    :operatingsystemrelease     => '7.1',
  }}

  let(:mount_base)            { '/var/artifactory' }
  let(:storage_props)         { "#{mount_base}/ha-etc/storage.properties" }
  let(:ha_node_file)          { "#{mount_base}/ha-node.properties.testhost.test.com" }


  context 'ha configuration files' do
    let(:facts) { basefacts }

    context 'with package installation' do
      let(:pre_condition) { 'class java {} ' }
      let(:params){{
        :ha_setup           => true,
        :ha_security_token  => '1234',
        :ha_primary_node    => false,
      }}
      it {
        should contain_file("#{mount_base}/ha-etc").with({:ensure => 'directory'})
        should contain_file("#{mount_base}/ha-data").with({:ensure => 'directory'})
        should contain_file("#{mount_base}/ha-backup").with({:ensure => 'directory'})
      }
      it {
        should contain_file("#{mount_base}/ha-etc/cluster.properties").with_content("security.token=1234\n").
        that_notifies('Service[artifactory]')
      }
      it {
        should contain_file(ha_node_file).
        that_notifies('Service[artifactory]').
        with_content(/node.id=testhost\n/)
      }
      it {
        should contain_file(ha_node_file).
        with_content(/cluster.home=\/var\/artifactory\n/)
      }
      it {
        should contain_file(ha_node_file).
        with_content(/context.url=http:\/\/1.2.3.4:8081\/artifactory\n/)
      }
      it {
        should contain_file(ha_node_file).
        with_content(/membership.port=10001\n/)
      }
      it {
        should contain_file(ha_node_file).
        with_content(/primary=false\n/)
      }
    end

    context 'with docker install (diffs only)' do
      let(:params){{
        :install_type       => 'docker',
        :ha_setup           => true,
        :ha_security_token  => '1234',
        :ha_primary_node    => true,
      }}
      it {
        should contain_file("#{mount_base}/ha-etc").with({:ensure => 'directory'})
        should contain_file("#{mount_base}/ha-data").with({:ensure => 'directory'})
        should contain_file("#{mount_base}/ha-backup").with({:ensure => 'directory'})
      }
      it {
        should contain_file("#{mount_base}/ha-etc/cluster.properties").with_content("security.token=1234\n").
        that_notifies('Docker::Run[artifactory_service]')
      }
      it {
        should contain_file(ha_node_file).
        that_notifies('Docker::Run[artifactory_service]').
        with_content(/node.id=testhost\n/)
      }
      it {
        should contain_file(ha_node_file).
        with_content(/primary=true\n/)
      }
    end

    context 'with custom context url' do
      let(:params){{
        :install_type       => 'docker',
        :ha_setup           => true,
        :ha_security_token  => '1234',
        :ha_primary_node    => true,
        :ha_context_url     => 'goobahyah'
      }}
      it {
        should contain_file(ha_node_file).
        with_content(/context.url=goobahyah\n/)
      }
    end

  end


  context 'db configuration file' do
    let(:pre_condition) { 'class java {} ' }
    let(:facts) { basefacts }

    let(:params){{
      :ha_setup           => true,
      :ha_security_token  => '1234',
      :ha_primary_node    => true,
      :configure_db       => true,
      :db_type            => 'postgresql',
    }}
    it {
      should contain_file("#{mount_base}/ha-etc/storage.properties").
      that_notifies('Service[artifactory]')
    }
  end

end
