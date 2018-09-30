# frozen_string_literal: true

# Run me with:
# bundle exec ruby doc/client_example.rb
require 'web_fetch'

$requests = [
  { url: 'http://localhost:8077/' },
  { url: 'http://yahoo.com/' },
  { url: 'http://lycos.com/' },
  { url: 'http://google.com/' }
]

# Wait for each response to return while iterating:
begin
  client = WebFetch::Client.new('localhost', 8077)
  responses = client.gather($requests)

  responses.each do |response|
    puts response.fetch(wait: true) # Will block (default behaviour)
  end
ensure
  client.stop
end


# Use a non-blocking call to `#fetch` and iterate over all responses until they
# are completed:
begin
  client = WebFetch::Client.new('localhost', 8077)
  responses = client.gather($requests)

  while responses.any? { |response| !response.complete? }
    responses.each do |response|
      response.fetch(wait: false) # Will not block
    end
  end
ensure
  client.stop
end
