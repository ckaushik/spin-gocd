require 'serverspec'
require 'net/ssh'
require 'net/ssh/proxy/command.rb'

module RemoteHost

  def 

set :backend, :ssh

host = ENV['TARGET_HOST']
bastion_host = ENV['BASTION_HOST']
user = 'ubuntu'
bastion_user = 'ubuntu'
private_key_file = '/home/vagrant/.ssh/spin-gocd-key'

options = Net::SSH::Config.for(host)
options[:auth_methods] = ['publickey']
options[:user] = user
options[:keys] = private_key_file
options[:forward_agent] = true
options[:paranoid] = false
options[:user_known_hosts_file] = '/dev/null'
options[:proxy] = Net::SSH::Proxy::Command.new("ssh -i #{private_key_file} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null #{bastion_user}@#{bastion_host} nc %h %p")
options[:timeout] = 10
# options[:verbose] = :info

set :host,        options[:host_name] || host
set :ssh_options, options

end
