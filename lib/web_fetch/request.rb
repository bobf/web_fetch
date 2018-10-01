# frozen_string_literal: true

module WebFetch
  class Request
    attr_writer :url, :query, :headers, :body, :custom
    attr_reader :url, :query, :headers, :body, :custom

    def initialize
      yield self
    end

    def method=(val)
      @method = val.downcase.to_sym
    end

    def method
      @method ||= :get
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
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      def build_request(hash)
        Request.new do |request|
          request.url = hash.delete(:url) if hash.key?(:url)
          request.query = hash.delete(:query) if hash.key?(:query)
          request.headers = hash.delete(:headers) if hash.key?(:headers)
          request.body = hash.delete(:body) if hash.key?(:body)
          request.method = hash.delete(:method) if hash.key?(:method)
          request.custom = hash.delete(:custom) if hash.key?(:custom)
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    end
  end
end
