require 'spec_helper'

describe 'artifactory' do

  context 'config' do
    let(:pre_condition) { 'class java {} ' }
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

    it { should create_file('/opt/jfrog/artifactory/tomcat/conf/server.xml').with(
      'ensure'  => 'file',
      'mode'    => '0444'
    ) }
  end
end
