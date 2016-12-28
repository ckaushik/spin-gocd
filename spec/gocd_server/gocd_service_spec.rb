require 'spec_helper_http'
require 'spec_helper_aws'

# describe alb('gocd-server-alb-sandbox') do

#   let(:gocd_service_hostname) {
#     described_class.dns_name
#   }

#   it { is_expected.to exist }

#   it 'has a reasonable-looking DNS name' do
#     expect(described_class.dns_name).to match /^gocd-server-alb-sandbox/
#   end

#   context 'from allowed IP address' do
#     it 'accepts HTTP connections' do
#       response = connect_with_retry("http://#{gocd_service_hostname}:8153/go/home")
#       expect(response.code).to eq('302')
#     end

#     it 'accepts HTTPS connections' do
#       response = connect_with_retry("https://#{gocd_service_hostname}:8154/go/home")
#       expect(response.code).to eq('302')
#     end
#   end

# end

