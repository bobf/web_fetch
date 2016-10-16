module WebFetch
  class Storage
    @_storage = {}

    def self.store(key, obj)
      @_storage[key] = obj
    end

    def self.fetch(key)
      @_storage[key]
    end
  end
end
