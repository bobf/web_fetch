# frozen_string_literal: true

module WebFetch
  module ClientHttp
    def base_uri
      "http://#{@host}:#{@port}"
    end

    def get(endpoint, params = {})
      conn = Faraday.new(url: base_uri)
      conn.get do |request|
        request.url "/#{endpoint}"
        request.params.merge!(params)
      end
    rescue Faraday::ConnectionFailed => e
      raise ClientError, e.message
    end

    def post(endpoint, body)
      conn = Faraday.new(url: base_uri)
      conn.post do |request|
        request.url "/#{endpoint}"
        request.body = body
      end
    rescue Faraday::ConnectionFailed => e
      raise ClientError, e.message
    end
  end
end
