module WebFetch
  # Client to be used in application code. Capable of spawning a server and
  # interacting with it to gather requests and retrieve them
  class Client
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
        response = get('')
      rescue Faraday::ConnectionFailed
        return false
      end
      return false unless response.success?
      JSON.parse(response.body)['application'] == 'WebFetch'
    end

    def gather(requests)
      json = JSON.dump(requests: requests)
      response = post('gather', json)
      return nil unless response.success?
      JSON.parse(response.body, symbolize_names: true)[:requests]
    end

    def retrieve_by_uid(uid)
      response = get('retrieve', uid: uid)
      return nil unless response.success?
      resp = JSON.parse(response.body, symbolize_names: true)
    end

    class << self
      def spawn(host, port, options)
        path = options.fetch(:path, standard_bin_file)
        args = [path, '--host', host, '--port', port.to_s]
        if options[:log]
          args.push('--log')
          args.push(options[:log])
        end
        process = ChildProcess.build(*args)
        process.environment['RUBYLIB'] = 'lib/'
        process.io.inherit!
        process.start
        process
      end

      private

      def standard_bin_file
        File.join(File.dirname(__dir__), '..', 'bin', 'web_fetch_server')
      end
    end

    private

    def base_uri
      "http://#{@host}:#{@port}"
    end

    def get(endpoint, params = {})
      conn = Faraday.new(url: base_uri)
      conn.get do |request|
        request.url "/#{endpoint}"
        request.params.merge!(params)
      end
    end

    def post(endpoint, body)
      conn = Faraday.new(url: base_uri)
      conn.post do |request|
        request.url "/#{endpoint}"
        request.body = body
      end
    end
  end
end
