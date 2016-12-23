require 'serverspec'
require 'net/ssh'
require 'net/ssh/proxy/command.rb'

set :backend, :ssh

def get_ssh_options(target_host,
                    target_host_key:,
                    bastion_host: nil,
                    bastion_host_key: nil)
  user = 'ubuntu'
  options = Net::SSH::Config.for(target_host)
  options[:host_name] = target_host
  options[:user] = user
  options[:auth_methods] = ['publickey']
  options[:keys] = target_host_key
  options[:user_known_hosts_file] = '/dev/null'
  options[:timeout] = 20
  # options[:verbose] = :debug

  unless bastion_host.nil?
    bastion_user = user
    options[:forward_agent] = true
    options[:paranoid] = false
    if bastion_host_key.nil?
      # We're assuming the same key is used for both hosts
      bastion_host_key = target_host_key
    end
    options[:proxy] = Net::SSH::Proxy::Command.new("ssh -i #{bastion_host_key} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null #{bastion_user}@#{bastion_host} nc %h %p")
  end

  options
end


