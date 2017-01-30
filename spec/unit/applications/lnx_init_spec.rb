require 'spec_helper'

describe 'nodejs_app', :type => :application do
  context 'supported linux operating systems' do
   on_supported_os({
      :hardwaremodels => ['x86_64'],
      :supported_os   => [
        {
          "operatingsystem" => "RedHat",
          "operatingsystemrelease" => [
            "6",
            "7"
          ]
        }
      ],
    }).each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "on a single node setup" do
          let(:title) { 'hello_world' }
          let(:node) { 'test.puppet.com' }

          let :params do
            {
              :app_name    => 'hello_world',
              :app_version => '0.1.0',
              :app_repo    => 'https://github.com/ipcrm/nodejs_hello_world.git',
              :nodes => {
                ref('Node', node) => [
                  ref('Nodejs_app::Appserver', 'hello_world'),
                ]
              }
            }
          end

          it { should compile }
          it { should contain_nodejs_app(title).with(
            'app_name'    => 'hello_world',
            'app_version' => '0.1.0',
            'app_repo'    => 'https://github.com/ipcrm/nodejs_hello_world.git',
          ) }

          it { should contain_nodejs_app__appserver("hello_world").with(
            'app_name'    => 'hello_world',
            'app_version' => '0.1.0',
            'app_repo'    => 'https://github.com/ipcrm/nodejs_hello_world.git',
            'vcsroot'     => nil,
          ) }

          it { should contain_class('nodejs') }

          it { should contain_package('pm2').with(
            'ensure'   => 'present',
            'provider' => 'npm',
          ).that_requires('Class[nodejs]') }

          case facts[:osfamily]
          when 'windows'

            it { should contain_file('C:\\nodejsapps').with(
              'ensure' => 'directory',
            ) }

            it { should contain_vcsrepo('C:\\nodejsapps\\hello_world').with(
              'ensure'   => 'present',
              'provider' => 'git',
              'source'   => 'https://github.com/ipcrm/nodejs_hello_world.git',
              'revision' => '0.1.0',
            )}

            it { should contain_exec('pm2_start_hello_world').with(
              'cwd'     => 'C:\\nodejsapps\\hello_world',
              'command' => 'pm2 start hello_world.config.js',
              'unless'  => 'pm2 show hello_world | findstr online',
            )}

          else

            it { should contain_file('/opt/nodejsapps').with(
              'ensure' => 'directory',
            ) }

            it { should contain_vcsrepo('/opt/nodejsapps/hello_world').with(
              'ensure'   => 'present',
              'provider' => 'git',
              'source'   => 'https://github.com/ipcrm/nodejs_hello_world.git',
              'revision' => '0.1.0',
            )}

            it { should contain_exec('pm2_start_hello_world').with(
              'cwd'     => '/opt/nodejsapps/hello_world',
              'command' => 'pm2 start hello_world.config.js',
              'unless'  => 'pm2 show hello_world | grep online',
            )}

          end

          it { should contain_http('hello_world')}
        end
      end
    end
  end
end
