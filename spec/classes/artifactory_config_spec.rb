require 'spec_helper'

describe 'artifactory::config', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should create_file('/opt/artifactory/tomcat/conf/server.xml').with(
    'ensure'  => 'file',
    'mode'    => '0444'
  ) }
end
