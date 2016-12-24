require 'uri'

def connect_with_retry(url)
  uri = URI.parse(url)
  Net::HTTP.get_response(uri)
rescue Errno::ECONNREFUSED => e
  retries ||= 0
  if retries < 36
    retries += 1
    sleep(5)
    retry
  else
    raise e
  end
end

