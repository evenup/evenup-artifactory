require 'spec_helper'

describe 'artifactory' do

  context 'install' do
    let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
    let(:params) { { :serverAlias => 'artifactory' } }

    it { should create_package('artifactory').with_ensure('latest') }
    it { should contain_apache__vhost('artifactory_80') }
    it { should contain_backups__archive('artifactory') }
  end

end
