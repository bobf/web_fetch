module WebFetch
  class Client
    def initialize(host, port)
      @host = host
      @port = port
    end

    def alive?
      response = get('/')
      response.code == 200 && response.body == 'WebFetch'
    end

    def fetch(requests)
      json = JSON.dump({ requests: requests })
      response = post('fetch', json: json)
      if response.code == 200
        symbolize(response.body['requests'])
      end
    end

    def retrieve_by_uid(uid)
      response = get('retrieve', uid: uid)
      if response.code == 200
        symbolize(response.body)
      elsif response.code == 404
        nil
      end
    end

    private

    def symbolize(obj)
      # >:)
      JSON.parse(JSON.dump(obj), symbolize_names: true)
    end

    def base_uri
      "http://#{@host}:#{@port}"
    end

    def get(endpoint, **params)
      Unirest.get("#{base_uri}/#{endpoint}",
                  headers: headers,
                  parameters: params)
    end

    def post(endpoint, params)
      Unirest.post("#{base_uri}/#{endpoint}",
                  headers: headers,
                  parameters: params)
    end

    def headers
      { 'Accept' => 'application/json' }
    end
  end
end
