require 'spec_helper_acceptance'

describe 'nodejs_app appserver define' do

		context 'deploy appserver and app' do
      it 'should work idempotently with no errors' do
        pp = <<-EOS
        package{'git': ensure => 'present'}
        nodejs_app::appserver {'hello_world':
          app_name    => 'hello_world',
          app_version => '0.1.0',
          app_repo    => 'https://github.com/ipcrm/nodejs_hello_world.git',
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end


      describe port(8000) do
          it { should be_listening }
      end

      describe command('curl --silent http://localhost:8000') do
          its(:stdout) { should match /html/ }
      end

      describe command('curl --silent http://localhost:8000') do
          its(:stdout) { should match /Puppet/ }
      end

      describe command('curl --silent http://localhost:8000/TESTVALUE') do
          its(:stdout) { should match /TESTVALUE/ }
      end

  end

end
