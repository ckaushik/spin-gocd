require 'serverspec'
require 'net/ssh'

set :backend, :ssh

host = ENV['TARGET_HOST']
options = Net::SSH::Config.for(host)
options[:timeout] = 10
# options[:verbose] = :info

set :host,        options[:host_name] || host
set :ssh_options, options
