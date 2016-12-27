require 'spec_helper_aws'
require 'spec_helper_http'

describe elb('gocd-server-alb-sandbox') do

  let(:gocd_service_hostname) {
    # described_class.dns_name
'gocd-server-alb-sandbox-2049151228.eu-west-1.elb.amazonaws.com'
  }

  # it { should exist }

  context 'from allowed IP address' do
    it 'accepts HTTP connections' do
      puts "Connecting to http://#{gocd_service_hostname}:8153/go/home"
      response = connect_with_retry("http://#{gocd_service_hostname}:8153/go/home")
      expect(response.code).to eq('302')
    end
  end

end

