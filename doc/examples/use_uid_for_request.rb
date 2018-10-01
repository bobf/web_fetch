# frozen_string_literal: true

# Run me with:
# bundle exec ruby doc/examples/use_uid_for_request.rb
#
# rubocop:disable all
require 'web_fetch'

def use_uid_for_request
  request = WebFetch::Request.new do |request|
    request.url = 'https://rubygems.org/'
  end

  client = WebFetch::Client.create('localhost', 8077)
  promises = client.gather([request])
  uid = promises.first.uid
  while true
    result = client.fetch(uid, wait: false)
    break unless result == :pending
  end

  puts result.body[0..100]

  client.stop
end

use_uid_for_request
# rubocop:enable all
