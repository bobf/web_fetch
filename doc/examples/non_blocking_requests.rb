# frozen_string_literal: true

# Run me with:
# bundle exec ruby doc/examples/non_blocking_requests.rb
#
# rubocop:disable all
require 'web_fetch'

def non_blocking_requests
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

  while promises.any? { |promise| !promise.complete? }
    promises.each do |promise|
      response = promise.fetch(wait: false) # Will not block
      puts response.body[0..100] unless response == :pending
    end
  end

  client.stop
end

non_blocking_requests
# rubocop:enable all
