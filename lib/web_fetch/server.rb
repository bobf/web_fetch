require 'reel'

module WebFetch
  class Server < Reel::Server::HTTP
    def initialize(host, port)
      super(host, port, &method(:on_connection))
      @router = Router.new
    end

    private

    def on_connection(connection)
      connection.each_request do |request|
        handle_request(request)
      end
    end

    def handle_request(request)
      response = @router.route(
        request.url, method: request.method,
                     query_string: query_string(request))

      request.respond(*response)
    end

    def query_string(request)
      if request.method == 'POST'
        request.body.to_s
      else
        request.query_string
      end
    end
  end
end
