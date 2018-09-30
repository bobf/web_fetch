# frozen_string_literal: true

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
      @server = options.delete(:server)
      options = { query_string: nil, method: 'GET' }.merge(options)
      method = options[:method].downcase.to_sym
      Logger.info("#{url}: #{options}")
      begin
        params = build_params(options)
      rescue JSON::ParserError
        return { status: 400, payload: I18n.t(:bad_json) }
      end
      route = @router.recognize(url, method: method)
      # Merge our hand-rolled params with the standard params (e.g. :uid)
      route.call(route.params.merge(params))
    end

    private

    # rubocop:disable Metrics/MethodLength
    def setup
      resource_finder = lambda do |name, env|
        Resources.public_send(name, @server, env)
      end

      Hanami::Router.new do
        get '/', to: lambda { |params|
          resource_finder.call(:root, params)
        }

        post '/gather', to: lambda { |params|
          resource_finder.call(:gather, params)
        }

        get '/retrieve/:uid', to: lambda { |params|
          resource_finder.call(:retrieve, params)
        }

        get '/find/:uid', to: lambda { |params|
          resource_finder.call(:find, params)
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def build_params(options)
      params = Rack::Utils.parse_nested_query(options[:query_string])
      merge_json!(params)
      params = symbolize(params)
      params.merge!(options[:post_data] || {})
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
