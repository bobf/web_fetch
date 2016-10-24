module WebFetch
  # Web server that accepts requests to gather and retrieve external HTTP
  # requests
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
      result = @router.route(@http_request_uri, request_params)
      response = EM::DelegatedHttpResponse.new(self)

      if result[:deferred].nil?
        respond_immediately(result, response)
      else
        wait_for_response(result[:deferred], response)
      end
    end

    def gather(requests)
      requests.each do |request|
        async_request = EM::HttpRequest.new(request[:request][:url])
        method = request[:request].fetch(:method, 'GET').downcase.to_sym
        http = async_request.public_send(method,
                                         head: request[:request][:headers])
        @storage.store(request[:uid], uid: request[:uid],
                                      http: http)
      end
    end

    private

    def request_params
      { method: @http_request_method,
        query_string: query_string,
        server: self }
    end

    def query_string
      if @http_request_method == 'POST'
        @http_post_content
      else
        @http_query_string
      end
    end

    def respond_immediately(result, response)
      response.status = result[:status]
      response.headers['Content-Type'] = 'application/json'
      response.content = JSON.dump(result[:payload])
      response.send_response
    end

    def wait_for_response(deferred, response)
      deferred[:http].callback { deferred[:succeeded] = true }
      deferred[:http].errback { deferred[:failed] = true }
      tick_loop(deferred, response)
    end

    def tick_loop(deferred, response)
      # XXX There may be a much nicer way to wait for an async task to complete
      # before returning a response but I couldn't figure it out, so I used
      # EM.tick_loop which effectively does the same as a Twisted deferred
      # callback chain, just much more explicitly.
      EM.tick_loop do
        if deferred[:succeeded]
          succeed(deferred, response)
          :stop
        elsif deferred[:failed]
          fail_(deferred, response)
          :stop
        end
      end
    end

    def succeed(deferred, response)
      response.status = 200
      response.content = JSON.dump(success(deferred))
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
      response.content = JSON.dump(failure(deferred))
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
