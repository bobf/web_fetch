# frozen_string_literal: true

module WebFetch
  # Web server that accepts requests to gather and retrieve external HTTP
  # requests
  class Server < EM::Connection
    attr_reader :storage

    include EM::HttpServer
    include HTTPHelpers

    def post_init
      super
      @router = Router.new
      @storage = WebFetch::Storage.create

      no_environment_strings
    end

    def process_http_request
      resource = @router.route(@http_request_uri, request_params)
      response = EM::DelegatedHttpResponse.new(self)
      default_headers(response)

      outcome(resource, response)
    end

    private

    def immediate?(command)
      %w[gather root].include?(command)
    end

    def outcome(resource, response)
      command = resource[:command]
      Logger.debug(command)
      return respond_immediately(resource, response) if immediate?(command)
      return pending(resource, response) if resource[:request][:pending]

      succeeded = resource[:request][:response][:success]
      return succeed(resource, response) if succeeded

      fail_(resource, response)
    end
  end
end
