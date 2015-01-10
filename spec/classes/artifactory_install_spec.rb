require 'spec_helper'

describe 'artifactory' do

  let(:pre_condition) { 'class java {} ' }

  context 'install' do
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
    let(:params) { { :serverAlias => 'artifactory' } }

    it { should create_package('artifactory').with_ensure('latest') }
  end

end
