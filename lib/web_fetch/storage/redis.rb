# frozen_string_literal: true

module WebFetch
  module Storage
    class Redis
      def initialize(client = nil)
        require 'redis' if client.nil?
        @client = client || ::Redis
        @config = {
          host: ENV.fetch('WEB_FETCH_REDIS_HOST', 'localhost'),
          port: ENV.fetch('WEB_FETCH_REDIS_PORT', '6379')
        }
      end

      def store(key, obj)
        storage.set(key, obj.to_json, ex: ttl)
      end

      def fetch(key)
        result = storage.get(key)
        return JSON.parse(result, symbolize_names: true) unless result.nil?

        nil
      end

      def delete(key)
        storage.del(key)
      end

      private

      def storage
        @storage ||= begin
          host = @config.fetch(:host)
          port = @config.fetch(:port)
          @client.new(url: "redis://#{host}:#{port}")
        end
      end

      def ttl
        @ttl ||= ENV.fetch('WEB_FETCH_REDIS_TTL', '60').to_i
      end
    end
  end
end
