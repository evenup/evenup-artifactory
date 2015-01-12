require 'spec_helper_acceptance'

describe 'artifactory class' do

  context 'setup' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'artifactory':
        ensure           => '3.4.2-30140',
        package_provider => 'rpm',
        package_source   => '/tmp/artifactory-3.4.2.rpm',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe user('artifactory') do
      it { should exist }
    end

    describe service('artifactory') do
      it { should be_running }
      it { should be_enabled }
    end

    describe port(8019) do
      it { should be_listening.with('tcp') }
    end

  end

end
