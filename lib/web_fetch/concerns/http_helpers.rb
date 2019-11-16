# frozen_string_literal: true

module WebFetch
  # Convenience methods for WebFetch HTTP layer
  module HTTPHelpers
    def respond_immediately(result, response)
      response.status = result[:status]
      response.content = compress(result[:payload].to_json)
      response.send_response
    end

    def pending(uid, response)
      respond_immediately({
                            payload: {
                              uid: uid,
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

    def succeed(resource, response)
      response.status = 200
      response.content = compress(JSON.dump(resource))
      storage.delete(resource[:request][:uid])
      response.send_response
    end

    def fail_(resource, response)
      response.status = 200
      response.content = compress(JSON.dump(resource))
      storage.delete(resource[:request][:uid])
      response.send_response
    end

    def accept_gzip?
      # em-http-request doesn't do us any favours with parsing the HTTP headers
      @http_headers.downcase.include?('accept-encoding: gzip')
    end
  end
end
