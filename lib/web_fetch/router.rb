require 'hanami/router'
require 'rack/utils'

module WebFetch
  class Router
    include Helpers

    def initialize
      @router = setup
    end

    def route(url, options = {})
      options = { query_string: nil, method: 'GET' }.merge(options)
      method = options[:method].downcase.to_sym

      params = Rack::Utils.parse_nested_query(options[:query_string])
      begin
        merge_json!(params)
      rescue JSON::ParserError
        return { status: 400, payload: I18n.t(:bad_json) }
      end
      params = symbolize(params)
      params[:_server] = options[:server]
      @router.recognize(url, method: method).call(params)
    end

    private

    def setup
      resource_finder = lambda do |name, env|
        Resources.public_send(name, env)
      end

      Hanami::Router.new do
        get '/', to: ->(params) do
          resource_finder.call(:root, params)
        end

        post '/fetch', to: ->(params) do
          resource_finder.call(:fetch, params)
        end

        get '/retrieve', to: ->(params) do
          resource_finder.call(:retrieve, params)
        end
      end
    end

    def merge_json(params)
      params.merge(
        JSON.parse(params.delete('json') || '{}',
                   symbolize_names: true))
    end

    def merge_json!(params)
      params.merge!(merge_json(params))
    end
  end
end
