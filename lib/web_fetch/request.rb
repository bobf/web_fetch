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

    def eql?(val)
      # Makes testing WebFetch a bit easier (based on real world case I hit
      # using WebFetch in a Rails app)
      val.to_h == to_h
    end

    def ==(val)
      eql?(val)
    end

    def self.from_hash(hash)
      hash = hash.dup
      new_request = Request.new do |request|
        request.url = hash.delete(:url) if hash.key?(:url)
        request.query = hash.delete(:query) if hash.key?(:query)
        request.headers = hash.delete(:headers) if hash.key?(:headers)
        request.body = hash.delete(:body) if hash.key?(:body)
        request.method = hash.delete(:method) if hash.key?(:method)
        request.custom = hash.delete(:custom) if hash.key?(:custom)
      end
      raise ArgumentError, "Unrecognized keys: #{hash}" unless hash.empty?
      new_request
    end
  end
end
