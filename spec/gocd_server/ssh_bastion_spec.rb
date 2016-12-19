require 'spec_helper_remote'

describe "bastion host" do

  host = ENV['BASTION_HOST']

  describe command('ls -al /') do
    its(:stdout) { should match /bin/ }
  end

  describe command('curl -sf --connect-timeout 10 http://kief.com') do
    its(:exit_status) { should eq 0 }
  end

end
