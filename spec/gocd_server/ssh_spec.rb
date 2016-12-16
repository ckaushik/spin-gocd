require 'spec_helper_remote'

describe command('ls -al /') do
  its(:stdout) { should match /bin/ }
end

