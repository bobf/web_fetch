# frozen_string_literal: true

module WebFetch
  # Convenience methods for WebFetch HTTP layer
  module HTTPHelpers
    def respond_immediately(result, response)
      response.status = result[:status]
      response.content = compress(result[:payload].to_json)
      response.send_response
    end

    def pending(result, response)
      respond_immediately({
                            payload: {
                              uid: result[:request][:uid],
                              pending: true,
                              message: I18n.t(:pending)
                            }
                          }, response)
    end

    def compress(string)
      return string unless accept_gzip?

      ActiveSupport::Gzip.compress(string)
    end

    def default_headers(response)
      response.headers['Content-Type'] = 'application/json; charset=utf-8'
      response.headers['Cache-Control'] = 'max-age=0, private, must-revalidate'
      response.headers['Content-Encoding'] = 'gzip' if accept_gzip?
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

    def succeed(request, response)
      response.status = 200
      response.content = compress(JSON.dump(success(request)))
      response.send_response
      storage.delete(request[:uid])
    end

    def success(request)
      result = request[:deferred]
      { response: {
        success: true,
        body: result.response,
        headers: result.headers,
        status: result.response_header.status,
        response_time: request[:response_time]
      },
        uid: request[:uid] }
    end

    def fail_(request, response)
      response.status = 200
      response.content = compress(JSON.dump(failure(request)))
      response.send_response
      storage.delete(request[:uid])
    end

    def failure(request)
      result = request[:deferred]
      { response: {
        success: false,
        body: result.response,
        headers: result.headers,
        status: result.response_header.status,
        response_time: request[:response_time],
        error: (result.error&.inspect)
      },
        uid: request[:uid] }
    end

    def accept_gzip?
      # em-http-request doesn't do us any favours with parsing the HTTP headers
      @http_headers.downcase.include?('accept-encoding: gzip')
    end
  end
end
