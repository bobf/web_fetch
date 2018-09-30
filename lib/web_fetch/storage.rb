# frozen_string_literal: true

module WebFetch
  # Rudimentary global storage for responses. The intention is that this will
  # one day prescribe an interface to e.g. memcached
  class Storage
    @storage = {}

    def self.store(key, obj)
      @storage[key] = obj
    end

    def self.fetch(key)
      @storage.fetch(key, nil)
    end

    def self.delete(key)
      @storage.delete(key)
    end
  end
end
