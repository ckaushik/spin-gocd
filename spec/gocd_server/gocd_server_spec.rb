require 'spec_helper_remote'
require 'spec_helper_aws'

describe ec2_running('GoCD Server') do

  before(:all) do
    target_host = described_class.private_ip
    bastion_host = ENV['BASTION_HOST']
    options = get_ssh_options(
      target_host,
      target_host_key: '/home/vagrant/.ssh/spin-gocd-key',
      bastion_host: bastion_host,
      bastion_host_key: '/home/vagrant/.ssh/spin-bastion-key'
    )
    set :host, target_host
    set :ssh_options, options
  end

  context 'within the environment' do
    it { should exist }
  end

  context 'on the server' do
    describe command('curl -sf --connect-timeout 10 http://kief.com') do
      its(:exit_status) { should eq 0 }
    end

    describe interface('eth0') do
      its(:ipv4_address) { should match /10\.0\.2\./ }
    end

    describe service('go-server') do
      it { should be_enabled }
    end
  end

end
