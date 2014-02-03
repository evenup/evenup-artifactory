require 'spec_helper'

describe 'artifactory' do

  context '#service' do
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

    it { should create_service('artifactory').with(
      'ensure'  => 'running',
      'enable'  => 'true'
    ) }
  end

end
