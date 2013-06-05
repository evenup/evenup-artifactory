require 'spec_helper'

describe 'artifactory::service', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should create_service('artifactory').with(
    'ensure'  => 'running',
    'enable'  => 'true'
  ) }

end
