require 'spec_helper_remote'
require 'spec_helper_aws'

describe "bastion host" do

  before(:all) do
    host = ENV['BASTION_HOST']
    # host = '52.213.188.102'

    options = get_ssh_options(host)
    set :ssh_options, options
    set :host, options[:host_name] || host
  end


  describe ec2_running('SSH Bastion Host') do
    it { should exist }
  end

  # describe command('ls -al /') do
  #   its(:stdout) { should match /bin/ }
  # end

  describe command('curl -sf --connect-timeout 10 http://kief.com') do
    its(:exit_status) { should eq 0 }
  end

  describe interface('eth0') do
    its(:ipv4_address) { should match /10\.0\.1\./ }
  end

end
