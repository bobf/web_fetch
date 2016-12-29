module WebFetch
  # Rudimentary global storage for responses
  class Storage
    @_storage = {}

    def self.store(key, obj)
      @_storage[key] = obj
    end

    def self.fetch(key)
      @_storage.delete(key)
    end
  end
end
