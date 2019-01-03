# frozen_string_literal: true

module WebFetch
  module Storage
    class Memory
      @storage = {}

      class << self
        attr_reader :storage
      end

      def clear
        self.class.storage.clear
      end

      def store(key, obj)
        storage[key] = obj
      end

      def fetch(key)
        storage.fetch(key, nil)
      end

      def delete(key)
        storage.delete(key)
      end

      private

      def storage
        self.class.storage
      end
    end
  end
end
