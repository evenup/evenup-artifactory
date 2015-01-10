require 'spec_helper'

describe 'artifactory', :type => :class do
  let(:pre_condition) { 'class java {} ' }
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should create_class('artifactory') }
  it { should contain_class('artifactory::install') }
  it { should contain_class('artifactory::config') }
  it { should contain_class('artifactory::service') }

end
