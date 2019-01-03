# frozen_string_literal: true

module WebFetch
  module Storage
    class Memcached
      def initialize
        @config = {
          host: ENV.fetch('WEB_FETCH_MEMCACHED_HOST', 'localhost'),
          port: ENV.fetch('WEB_FETCH_MEMCACHED_PORT', '11211')
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
          Dalli::Client.new("#{host}:#{port}")
        end
      end
    end
  end
end
