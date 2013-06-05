require 'spec_helper'

describe 'artifactory::fetch_artifact', :type => :define do
  let(:title) { 'myproject' }

  context "project, version, format, path provided, no filename, repo or server" do
    let(:params) { {
      :project      => 'foo',
      :version      => '1.2.3',
      :format       => 'war',
      :path         => 'usr',
      :install_path => '/somewhere',
    } }

    it { should contain_exec('artifactory_fetch_myproject').with(
      'creates' => '/somewhere/foo-1.2.3.war',
      'command' => "curl -o /somewhere/foo-1.2.3.war http://artifactory/artifactory/libs-release-local/usr/foo/1.2.3/foo-1.2.3.war"
    ) }
  end

  context "project, version, format, path, filename provided, no repo or server" do
    let(:params) { {
      :project      => 'foo',
      :version      => '1.2.3',
      :format       => 'war',
      :filename     => 'monkeys.test',
      :install_path => '/somewhere'
    } }

    it { should contain_exec('artifactory_fetch_myproject').with(
      'creates' => '/somewhere/monkeys.test'
    ) }
  end

  context "project, version, format, server, repo provided, no filename" do
    let(:params) { {
      :project => 'foo',
      :version => '1.2.3',
      :format => 'war',
      :server => 'http://server1',
      :repo => 'test',
      :install_path => '/somewhere'
    } }

    it { should contain_exec('artifactory_fetch_myproject').with(
      'creates' => '/somewhere/foo-1.2.3.war',
      'command' => "curl -o /somewhere/foo-1.2.3.war http://server1/artifactory/test//foo/1.2.3/foo-1.2.3.war"
    ) }
  end

end
