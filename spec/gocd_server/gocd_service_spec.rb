require 'spec_helper_http'

describe 'gocd_service' do

  let(:gocd_service_hostname) {
    'gocd.sandbox.cloudspin.net'
  }

  context 'from allowed IP address' do
    it 'accepts HTTP connections' do
      puts "Connect to: http://#{gocd_service_hostname}/go/home"
      response = connect_with_retry("http://#{gocd_service_hostname}/go/home")
      expect(response.code).to eq('302')
    end

    it 'accepts HTTPS connections' do
      puts "Connect to: https://#{gocd_service_hostname}/go/home"
      response = connect_with_retry("https://#{gocd_service_hostname}/go/home")
      expect(response.code).to eq('302')
    end
  end

end

