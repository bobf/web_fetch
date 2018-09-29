# frozen_string_literal: true

module WebFetch
  # Web server that accepts requests to gather and retrieve external HTTP
  # requests
  class Server < EM::Connection
    attr_reader :storage

    include EM::HttpServer
    include WebFetch::HttpHelpers

    def post_init
      super
      @router = Router.new
      @storage = Storage
      no_environment_strings
    end

    def process_http_request
      result = @router.route(@http_request_uri, request_params)
      response = EM::DelegatedHttpResponse.new(self)

      default_headers(response)

      if result[:deferred].nil?
        respond_immediately(result, response)
      else
        wait_for_response(result[:deferred], response)
      end
    end

    def gather(targets)
      targets.each do |target|
        request = target[:request]
        async_request = EM::HttpRequest.new(request[:url])
        method = request.fetch(:method, 'GET').downcase.to_sym
        http = async_request.public_send(method,
                                         head: request[:headers],
                                         query: request.fetch(:query, {}),
                                         body: request.fetch(:body, nil))
        @storage.store(target[:uid], uid: target[:uid], http: http)
      end
    end

    private

    def respond_immediately(result, response)
      response.status = result[:status]
      response.content = compress(result[:payload].to_json)
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
  end
end
