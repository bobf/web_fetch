# frozen_string_literal: true

# Run me with:
# bundle exec ruby doc/examples/blocking_requests.rb
#
# rubocop:disable all
require 'web_fetch'

def blocking_requests
  urls = ['https://rubygems.org/',
          'http://lycos.com/',
          'http://google.com/']

  requests = urls.map do |url|
    WebFetch::Request.new do |request|
      request.url = url
    end
  end

  client = WebFetch::Client.create('localhost', 8077)
  promises = client.gather(requests)

  promises.each do |promise|
    response = promise.fetch(wait: true) # Will block (default behaviour)
    puts response.body[0..100]
    puts "Success: #{response.success?}"
  end

  client.stop
end

blocking_requests
# rubocop:enable all
