module WebFetch
  # Client to be used in application code. Capable of spawning a server and
  # interacting with it to gather requests and retrieve them
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
      sleep 0.1 until client.alive?
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
      response.code == 200 && response.body['application'] == 'WebFetch'
    end

    def gather(requests)
      json = JSON.dump(requests: requests)
      response = post('gather', json: json)
      symbolize(response.body['requests']) if response.code == 200
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
        process = ChildProcess.build(path, '--host', host, '--port', port.to_s)
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
