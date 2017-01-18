module WebFetch
  # Convenience methods for WebFetch HTTP layer
  module HTTPHelpers
    def respond_immediately(result, response)
      response.status = result[:status]
      response.content = compress(result[:payload].to_json)
      response.send_response
    end

    def compress(string)
      ActiveSupport::Gzip.compress(string)
    end

    def default_headers(response)
      response.headers['Content-Type'] = 'application/json; charset=utf-8'
      response.headers['Cache-Control'] = 'max-age=0, private, must-revalidate'
      response.headers['Content-Encoding'] = 'gzip'
      response.headers['Vary'] = 'Accept-Encoding'
    end

    def request_params
      { method: @http_request_method,
        query_string: @http_query_string,
        post_data: post_data,
        server: self }
    end

    def post_data
      return nil unless @http_post_content
      JSON.parse(@http_post_content, symbolize_names: true)
    end

    def succeed(deferred, response)
      response.status = 200
      response.content = compress(JSON.dump(success(deferred)))
      response.send_response
    end

    def success(deferred)
      result = deferred[:http]
      { response: {
        success: true,
        body: result.response,
        headers: result.headers,
        status: result.response_header.status
      },
        uid: deferred[:uid] }
    end

    def fail_(deferred, response)
      response.status = 200
      response.content = compress(JSON.dump(failure(deferred)))
      response.send_response
    end

    def failure(deferred)
      result = deferred[:http]
      { response: {
        success: false,
        body: result.response,
        headers: result.headers,
        status: result.response_header.status,
        error: (result.error.inspect unless result.error.nil?)
      },
        uid: deferred[:uid] }
    end
  end
end
