module WebFetch
  class Request
    attr_writer :url, :query, :headers, :body
    attr_reader :url, :query, :headers, :body

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
        method: method
      }
    end
  end
end
