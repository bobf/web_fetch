module WebFetch
  class Client
    include Helpers

    def initialize(host, port, options = {})
      @host = host
      @port = port
      @process = options[:process]
    end

    def self.create(host, port, options = {})
      # Will block until process is responsive
      process = spawn(host, port, options)
      client = new(host, port, process: process)
      while not client.alive?
        sleep 0.1
      end
      client
    end

    def stop
      # Will block until process dies
      return if @process.nil?
      @process.stop
      @process.wait
    end

    def alive?
      begin
        response = get('/')
      rescue Errno::ECONNREFUSED
        return false
      end
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

    class << self
      def spawn(host, port, options)
        path = options.fetch(:path, 'bin/web_fetch_server')
        process = ChildProcess.build(path, '--host', host, '--port', "#{port}")
        process.environment['RUBYLIB'] = 'lib/'
        process.io.inherit!
        process.start
        process
      end
    end

    private

    def base_uri
      "http://#{@host}:#{@port}"
    end

    def get(endpoint, params = {})
      Unirest.get("#{base_uri}/#{endpoint}",
                  headers: headers,
                  parameters: params)
    end

    def post(endpoint, params = {})
      Unirest.post("#{base_uri}/#{endpoint}",
                  headers: headers,
                  parameters: params)
    end

    def headers
      { 'Accept' => 'application/json' }
    end
  end
end
