# frozen_string_literal: true

# Run me with:
# bundle exec ruby doc/client_example.rb
#
# rubocop:disable all
require 'web_fetch'

urls = ['https://rubygems.org/',
        'http://lycos.com/',
        'http://google.com/']

$requests = urls.map do |url|
  WebFetch::Request.new do |request|
    request.url = url
  end
end

begin
  # Wait for each response to return while iterating:
  client = WebFetch::Client.create('localhost', 8077)
  responses = client.gather($requests)

  responses.each do |response|
    result = response.fetch(wait: true) # Will block (default behaviour)
    puts result.body[0..100]
    puts "Success: #{result.success?}"
  end

  # Use a non-blocking call to `#fetch` and iterate over all responses until
  # they are completed:
  client = WebFetch::Client.create('localhost', 8077)
  responses = client.gather($requests)

  while responses.any? { |response| !response.complete? }
    responses.each do |response|
      result = response.fetch(wait: false) # Will not block
      puts result.body[0..100] unless result == :pending
    end
  end

  # Use uid to fetch result (useful if you do not have the Response object
  # still available - the uid can be persisted and used to fetch the result
  # later.
  responses = client.gather([$requests.first])
  uid = responses.first.uid
  while true
    result = client.fetch(uid, wait: false)
    break unless result == :pending
  end

  puts result.body[0..100]
ensure
  client.stop
end
# rubocop:enable all
