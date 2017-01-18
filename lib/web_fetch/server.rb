# frozen_string_literal: true

module WebFetch
  # Web server that accepts requests to gather and retrieve external HTTP
  # requests
  class Server < EM::Connection
    attr_reader :storage

    include EM::HttpServer
    include HTTPHelpers
    include EventMachineHelpers

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

    # Note that #gather is called by WebFetch itself to asynchronously gather
    # the required HTTP objects. All public API requests go via
    # #process_http_request and subsequently WebFetch::Router#route
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
  end
end
