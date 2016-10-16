module WebFetch
  class Server < EM::Connection
    attr_reader :storage

    include EM::HttpServer

     def post_init
       super
       @router = Router.new
       @storage = Storage
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
      result = @router.route(
        @http_request_uri, method: @http_request_method,
                           query_string: query_string,
                           server: self)
      response = EM::DelegatedHttpResponse.new(self)

      if result[:deferred].nil?
        response.status = result[:status]
        response.headers['Content-Type'] = 'application/json'
        response.content = result[:payload]
        response.send_response
      else
        wait_for_response(result[:deferred], response)
      end
    end

    def gather(requests)
      requests.each do |request|
        http = EM::HttpRequest.new(request[:request][:url]).get
        @storage.store(request[:uid], uid: request[:uid],
                                      http: http)
      end
    end

    private

    def query_string
      if @http_request_method == 'POST'
        @http_post_content
      else
        @http_query_string
      end
    end

    def wait_for_response(deferred, response)
      deferred[:http].callback { deferred[:succeeded] = true }
      deferred[:http].errback { deferred[:failed] = true }
      # XXX There may be a much nicer way to wait for an async task to complete
      # before returning a response but I couldn't figure it out, so I used
      # EM.tick_loop which effectively does the same as a Twisted deferred
      # callback chain, just much more explicitly.
      tickloop = EM.tick_loop do
        if deferred[:succeeded] 
          response.status = 200
          response.content = JSON.dump(success(deferred))
          response.send_response
          :stop
        elsif deferred[:failed]
          response.status = 200
          response.content = JSON.dump(failure(deferred))
          response.send_response
          :stop
        end
      end
    end

    def success(deferred)
      result = deferred[:http]
      { response: {
          success: true,
          body: result.response,
          headers: result.headers,
          status: result.response_header.status
        },
        uid: deferred[:uid]
      }
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
        uid: deferred[:uid]
      }
    end
  end
end
