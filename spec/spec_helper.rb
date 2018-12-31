# frozen_string_literal: true

require 'web_fetch'
require 'pp'
require 'byebug'
require 'webmock/rspec'
require 'rspec/its'

WebMock.disable_net_connect!(allow_localhost: true)

# This is pretty ugly but seems to do the job
puts 'Starting test server'
WebFetch::Logger.logger(File::NULL)

Thread.new do
  EM.run do
    EM.start_server 'localhost', 60_085, WebFetch::Server
  end
end
waiting = true
while waiting
  begin
    res = Faraday.get('http://localhost:8089/')
  rescue Faraday::ConnectionFailed
    res = nil
  end
  waiting = !res.nil? && res.status != 200
  sleep 0.1
end
puts 'Test server started'

module WebFetch
  class MockServer
    def gather(requests); end

    def storage
      Storage::Memory.new
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.order = :random

  Kernel.srand config.seed
end
