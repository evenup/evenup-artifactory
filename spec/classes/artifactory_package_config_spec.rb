require 'spec_helper'

describe 'artifactory' do

  context 'config' do
    let(:pre_condition) { 'class java {} ' }
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

    context 'default' do
      it { should create_file('/opt/jfrog/artifactory/tomcat/conf/server.xml').with(:content => /port="8019"/) }
    end

    context 'set ajp port' do
      let(:params) { { :ajp_port => 8091 } }
      it { should create_file('/opt/jfrog/artifactory/tomcat/conf/server.xml').with(:content => /port="8091"/) }
    end

    context 'license file' do
      let(:params) {{ :license_content => 'abcd' }}
      it {
        should create_file('/var/opt/jfrog/artifactory/etc/artifactory.lic').
        with({ :ensure => 'link', :target => '/etc/artifactory/artifactory.lic' })
      }
    end

  end
end
