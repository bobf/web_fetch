# frozen_string_literal: true

module WebFetch
  module Storage
    class Redis
      def initialize
        @config = {
          host: ENV.fetch('WEB_FETCH_REDIS_HOST', 'localhost'),
          port: ENV.fetch('WEB_FETCH_REDIS_PORT', '6379')
        }
      end

      def store(key, obj)
        storage.set(key, obj.to_json)
      end

      def fetch(key)
        JSON.parse(storage.get(key), symbolize_names: true)
      end

      def delete(key)
        storage.delete(key)
      end

      private

      def storage
        @storage ||= begin
          require 'dalli'
          host = @config.fetch(:host)
          port = @config.fetch(:port)
          Dalli::Client.new("#{host}:#{port}", expires_in: ttl)
        end
      end

      def ttl
        ENV.fetch('WEB_FETCH_MEMCACHED_TTL', '60').to_i
      end
    end
  end
end
