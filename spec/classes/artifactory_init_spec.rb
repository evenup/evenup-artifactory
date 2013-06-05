require 'spec_helper'
 
describe 'artifactory', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should create_class('artifactory') }
  it { should create_package('artifactory').with_ensure('latest') }
  it { should create_service('artifactory').with(
    'ensure'  => 'running',
    'enable'  => 'true'
  ) }
    
  it { should create_file('/opt/artifactory/tomcat/conf/server.xml').with(
    'ensure'  => 'file',
    'mode'    => '0444'
  ) }
    
  it { should contain_apache__vhost('artifactory_80') }
  it { should contain_backups__archive('artifactory') }

end
