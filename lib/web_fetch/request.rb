# frozen_string_literal: true

module WebFetch
  class Request
    attr_writer :url, :query, :headers, :body, :custom, :method
    attr_reader :url, :query, :headers, :body, :custom

    def initialize
      @method = 'GET'
      yield self
    end

    def method
      @method.downcase.to_sym
    end

    def to_h
      {
        url: url,
        query: query,
        headers: headers,
        body: body,
        method: method,
        custom: custom
      }
    end

    def eql?(other)
      # Makes testing WebFetch a bit easier (based on real world case I hit
      # using WebFetch in a Rails app)
      other.to_h == to_h
    end

    def ==(other)
      eql?(other)
    end

    def self.from_hash(hash)
      hash_copy = hash.dup
      request = build_request(hash_copy)
      raise ArgumentError, "Unrecognized keys: #{hash}" unless hash_copy.empty?

      request
    end

    class << self
      def build_request(hash)
        Request.new do |request|
          %i[url query headers body method custom].each do |key|
            request.send("#{key}=", hash.delete(key))
          end
        end
      end
    end
  end
end
