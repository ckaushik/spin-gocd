require 'spec_helper_remote'
require 'spec_helper_aws'

describe ec2_running('SSH Bastion Host') do

  before(:all) do
    host = described_class.public_ip
    options = get_ssh_options(host)
    set :ssh_options, options
    set :host, options[:host_name] || host
  end

  context 'within the environment' do
    it { should exist }
  end

  context 'on the server' do
    describe command('curl -sf --connect-timeout 10 http://kief.com') do
      its(:exit_status) { should eq 0 }
    end

    describe interface('eth0') do
      its(:ipv4_address) { should match /10\.0\.1\./ }
    end
  end

end
