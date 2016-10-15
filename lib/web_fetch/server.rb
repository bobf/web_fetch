module WebFetch
  class Server < EM::Connection
    include EM::HttpServer

     def post_init
       super
       @router = Router.new
       no_environment_strings
     end

    def process_http_request
      # the http request details are available via the following instance variables:
      #   @http_protocol
      #   @http_request_method
      #   @http_cookie
      #   @http_if_none_match
      #   @http_content_type
      #   @http_path_info
      #   @http_request_uri
      #   @http_query_string
      #   @http_post_content
      #   @http_headers
      status, payload = @router.route(
        @http_request_uri, method: @http_request_method,
                           query_string: query_string)

      response = EM::DelegatedHttpResponse.new(self)
      response.status = status
      response.headers['Content-Type'] = 'application/json'
      response.content = payload
      response.send_response
    end

    def query_string
      if @http_request_method == 'POST'
        @http_post_content
      else
        @http_query_string
      end
    end
  end
end
