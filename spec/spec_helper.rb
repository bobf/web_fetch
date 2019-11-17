# frozen_string_literal: true

require 'betterp'
require 'byebug'
require 'pp'
require 'rspec/its'
require 'web_fetch'
require 'webmock/rspec'

require File.join(__dir__, 'storage', 'shared_examples')

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

    def self.storage
      @storage ||= Storage::Memory.new
    end

    def storage
      self.class.storage
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:each) { WebFetch::MockServer.storage.clear }
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # config.order = :random
  #
  # Kernel.srand config.seed
end
