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

    it { should contain_artifactory__fetch_artifact_generic('fetch_artifact_generic_myproject').with(
      'install_path' => '/somewhere',
      'base_path' => 'http://artifactory/artifactory',
      'repo' => 'libs-release-local',
      'filename' => 'foo-1.2.3.war',
      'source_file' => 'foo-1.2.3.war',
      'layout' => "usr/foo/1.2.3"
      ) }
  end

  context "project, version, format, path, filename, repo, server provided" do
    let(:params) { {
        :project      => 'foo',
        :version      => '1.2.3',
        :format       => 'war',
        :server       => 'http://server1',
        :repo         => 'test',
        :filename     => 'monkeys.test',
        :install_path => '/somewhere'
      } }

    it { should contain_artifactory__fetch_artifact_generic('fetch_artifact_generic_myproject').with(
      'install_path' => '/somewhere',
      'base_path' => 'http://server1/artifactory',
      'repo' => 'test',
      'filename' => 'monkeys.test',
      'source_file' => 'foo-1.2.3.war',
      'layout' => '/foo/1.2.3'
      ) }
  end

  context "project, version, format, server, repo provided, no filename" do
    let(:params) { {
        :project      => 'foo',
        :version      => '1.2.3',
        :format       => 'war',
        :server       => 'http://server1',
        :repo         => 'test',
        :install_path => '/somewhere'
      } }

    it { should contain_artifactory__fetch_artifact_generic('fetch_artifact_generic_myproject').with(
      'install_path' => '/somewhere',
      'base_path' => 'http://server1/artifactory',
      'repo' => 'test',
      'filename' => 'foo-1.2.3.war',
      'source_file' => 'foo-1.2.3.war',
      'layout' => '/foo/1.2.3'
      ) }
  end

  context "project, version , source_file" do
    let(:params) { {
        :project => 'foo',
        :version => '1.2.3',
        :format => 'war',
        :server => 'http://server1',
        :repo => 'test',
        :install_path => '/somewhere',
        :source_file => 'bar-2.3.4-all.war'
      } }

    it { should contain_artifactory__fetch_artifact_generic('fetch_artifact_generic_myproject').with(
      'install_path' => '/somewhere',
      'base_path' => 'http://server1/artifactory',
      'repo' => 'test',
      'filename' => 'foo-1.2.3.war',
      'source_file' => 'bar-2.3.4-all.war',
      'layout' => '/foo/1.2.3'
      ) }

  end

end
