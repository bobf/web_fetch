# frozen_string_literal: true

module WebFetch
  module Storage
    class << self
      def create
        {
          'memory' => Memory,
          'memcached' => Memcached
        }.fetch(backend).new
      end

      private

      def backend
        ENV.fetch('WEB_FETCH_BACK_END', 'memory')
      end
    end
  end
end

require 'web_fetch/storage/memcached'
require 'web_fetch/storage/memory'
