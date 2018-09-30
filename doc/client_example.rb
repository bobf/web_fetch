# frozen_string_literal: true

# Run me with:
# bundle exec ruby doc/client_example.rb
require 'web_fetch'

urls = ['http://localhost:8077/',
        'http://yahoo.com/',
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
    puts response.fetch(wait: true) # Will block (default behaviour)
  end

  # Use a non-blocking call to `#fetch` and iterate over all responses until
  # they are completed:
  client = WebFetch::Client.create('localhost', 8077)
  responses = client.gather($requests)

  while responses.any? { |response| !response.complete? }
    responses.each do |response|
      response.fetch(wait: false) # Will not block
    end
  end
ensure
  client.stop
end
