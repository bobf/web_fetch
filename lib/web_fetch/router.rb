require 'hanami/router'
require 'rack/utils'

module WebFetch
  # Dispatches requests to correct resource
  class Router
    include Helpers

    def initialize
      @router = setup
    end

    def route(url, options = {})
      options = { query_string: nil, method: 'GET' }.merge(options)
      method = options[:method].downcase.to_sym
      begin
        params = build_params(options)
      rescue JSON::ParserError
        return { status: 400, payload: I18n.t(:bad_json) }
      end
      @router.recognize(url, method: method).call(params)
    end

    private

    # rubocop:disable Metrics/MethodLength
    def setup
      resource_finder = lambda do |name, env|
        Resources.public_send(name, env)
      end

      Hanami::Router.new do
        get '/', to: lambda { |params|
          resource_finder.call(:root, params)
        }

        post '/gather', to: lambda { |params|
          resource_finder.call(:gather, params)
        }

        get '/retrieve', to: lambda { |params|
          resource_finder.call(:retrieve, params)
        }
      end
    end
    # rubocop:enable

    def build_params(options)
      params = Rack::Utils.parse_nested_query(options[:query_string])
      merge_json!(params)
      params = symbolize(params)
      params.merge!(options[:post_data] || {})
      params[:_server] = options[:server]
      params
    end

    def merge_json(params)
      params.merge(
        JSON.parse(params.delete('json') || '{}',
                   symbolize_names: true)
      )
    end

    def merge_json!(params)
      params.merge!(merge_json(params))
    end
  end
end
