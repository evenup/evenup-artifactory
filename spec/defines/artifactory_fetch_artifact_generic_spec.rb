require 'spec_helper'

describe 'artifactory::fetch_artifact_generic', :type => :define do
  let(:title) { 'myproject' }

  context "Linux: install_path, source_file, layout provided, no filename, base_path or repo" do
    let(:params) { {
        :install_path => '/somewhere',
        :source_file  => 'test.jar',
        :layout       => 'myapp',
      } }

    it { should contain_exec('artifactory_fetch_myproject').with(
      'creates' => '/somewhere/test.jar',
      'command' => "curl -o /somewhere/test.jar http://artifactory/artifactory/libs-release-local/myapp/test.jar"
      ) }
  end

  context "Windows OS: install_path, source_file, layout provided, no filename, base_path or repo" do
    let :facts do{
        :osfamily     => 'windows'
      }end
    let(:params) { {
        :install_path => '/somewhere',
        :source_file  => 'test.jar',
        :layout       => 'myapp',
      } }

    it { should contain_exec('artifactory_fetch_myproject').with(
      'creates' => '/somewhere/test.jar',
      'command' => "Import-Module BitsTransfer; Start-BitsTransfer -Source http://artifactory/artifactory/libs-release-local/myapp/test.jar -Destination /somewhere"
      ) }
  end
  
  context "Windows OS: install_path, source_file, layout provided, filename no base_path or repo" do
      let :facts do{
          :osfamily     => 'windows'
        }end
      let(:params) { {
          :install_path => '/somewhere',
          :source_file  => 'test.jar',
          :layout       => 'myapp',
          :filename     => 'downloaded.jar',
        } }
  
      it { should contain_exec('artifactory_fetch_myproject').with(
        'creates' => '/somewhere/downloaded.jar',
        'command' => "Import-Module BitsTransfer; Start-BitsTransfer -Source http://artifactory/artifactory/libs-release-local/myapp/test.jar -Destination /somewhere"
        ) }
    end
    
  context "Windows OS: install_path, source_file, layout provided, filename, base_path no repo" do
        let :facts do{
            :osfamily     => 'windows'
          }end
        let(:params) { {
            :install_path => '/somewhere',
            :source_file  => 'test.jar',
            :layout       => 'myapp',
            :filename     => 'downloaded.jar',
            :base_path    => 'http://myhost/myrepository',
          } }
    
        it { should contain_exec('artifactory_fetch_myproject').with(
          'creates' => '/somewhere/downloaded.jar',
          'command' => "Import-Module BitsTransfer; Start-BitsTransfer -Source http://myhost/myrepository/libs-release-local/myapp/test.jar -Destination /somewhere"
          ) }
      end

  context "Windows OS: all parameters" do
          let :facts do{
              :osfamily     => 'windows'
            }end
          let(:params) { {
              :install_path => '/somewhere',
              :source_file  => 'test.jar',
              :layout       => 'myapp',
              :filename     => 'downloaded.jar',
              :base_path    => 'http://myhost/myrepository',
              :repo         => 'mysimple',
            } }
      
          it { should contain_exec('artifactory_fetch_myproject').with(
            'creates' => '/somewhere/downloaded.jar',
            'command' => "Import-Module BitsTransfer; Start-BitsTransfer -Source http://myhost/myrepository/mysimple/myapp/test.jar -Destination /somewhere"
            ) }
        end
end
