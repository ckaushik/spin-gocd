require 'spec_helper_remote'
require 'spec_helper_aws'

describe "private_instance" do

  before(:all) do
    host = ENV['TARGET_HOST']
    bastion_host = ENV['BASTION_HOST']
    # host = '10.0.2.18'
    # bastion_host = '52.213.188.102'

    options = get_ssh_options(host, bastion_host)
    set :host, options[:host_name] || host
    set :ssh_options, options
  end

  describe ec2_running('GoCD Server') do
    it { should exist }
  end

  # describe ec2_instances_tagged('Name = GoCD Server') do

  #   its(:size ) { should_be equal_to(1) }

  #   describe command('ls -al /') do
  #     its(:stdout) { should match /bin/ }
  #   end

  # end

  # describe command('ls -al /') do
  #   its(:stdout) { should match /bin/ }
  # end

  describe command('curl -sf --connect-timeout 10 http://kief.com') do
    its(:exit_status) { should eq 0 }
  end

  describe interface('eth0') do
    its(:ipv4_address) { should match /10\.0\.2\./ }
  end

end
