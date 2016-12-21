require 'serverspec'
require 'net/ssh'
require 'net/ssh/proxy/command.rb'

set :backend, :ssh

def get_ssh_options(host, bastion_host = nil)
  user = 'ubuntu'
  private_key_file = '/home/vagrant/.ssh/spin-gocd-key'
  options = Net::SSH::Config.for(host)
  options[:auth_methods] = ['publickey']
  options[:user] = user
  options[:keys] = private_key_file
  options[:user_known_hosts_file] = '/dev/null'
  # options[:verbose] = :debug
  options[:timeout] = 10
  unless bastion_host.nil?
    options[:forward_agent] = true
    options[:paranoid] = false
    bastion_user = 'ubuntu'
    options[:proxy] = Net::SSH::Proxy::Command.new("ssh -i #{private_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null #{bastion_user}@#{bastion_host} nc %h %p")
  end
  options
end

