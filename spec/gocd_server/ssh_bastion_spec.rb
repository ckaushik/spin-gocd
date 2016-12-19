require 'spec_helper_remote'
require 'spec_helper_aws'

describe "bastion host" do

  host = ENV['BASTION_HOST']

  describe ec2('SSH Bastion Host') do
    it { should be_running }
  end

  describe command('ls -al /') do
    its(:stdout) { should match /bin/ }
  end

  describe command('curl -sf --connect-timeout 10 http://kief.com') do
    its(:exit_status) { should eq 0 }
  end

  describe interface('eth0') do
    its(:ipv4_address) { should match /10\.0\.1\./ }
  end

end
