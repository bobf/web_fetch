# frozen_string_literal: true

module WebFetch
  # Client to be used in application code. Capable of spawning a server and
  # interacting with it to gather requests and retrieve them
  class Client
    include ClientHttp

    attr_reader :host, :port

    def initialize(host, port, options = {})
      @host = host
      @port = port
      @process = options[:process]
    end

    def self.create(host, port, options = {})
      # Will block until process is responsive
      process = build_process(host, port, options)
      client = new(host, port, process: process)
      sleep 0.1 until client.alive?
      client
    end

    def stop
      return if @process.nil?

      @process.terminate
      # Will block until process dies
      @process.wait
    end

    def alive?
      begin
        response = get('')
      rescue ClientError
        return false
      end
      return false unless response.success?

      JSON.parse(response.body)['application'] == 'WebFetch'
    end

    def gather(requests)
      json = JSON.dump(requests: requests.map(&:to_h))
      response = post('gather', json)

      handle_error(JSON.parse(response.body)['error']) unless response.success?

      requests = JSON.parse(response.body, symbolize_names: true)[:requests]

      promises(requests)
    end

    def fetch(uid, options = {})
      block = options.fetch(:wait, true)

      outcome = block ? fetch_blocking(uid) : fetch_nonblocking(uid)
      no_request_error(uid) if outcome.nil?

      Response.new(outcome.merge(uid: uid))
    end

    def retrieve_by_uid(uid)
      fetch_blocking(uid)[:request]
    end

    def find_by_uid(uid)
      fetch_nonblocking(uid)[:request]
    end

    class << self
      def build_process(host, port, options)
        command = options.fetch(:start_command, standard_start_command)
        args = ['--host', host, '--port', port.to_s]
        args += ['--log', options[:log]] unless options[:log].nil?
        args.push('--daemonize') if options[:daemonize]
        Subprocess.popen(command + args, cwd: cwd)
      end

      def cwd
        File.join(File.dirname(__dir__), '..')
      end

      def standard_start_command
        %w[bundle exec ./bin/web_fetch_control run --]
      end
    end

    private

    def decode_response(response)
      return response unless response[:command] == 'retrieve'

      response[:request][:response][:body] = Base64.decode64(
        response[:request][:response][:body]
      )
      response
    end

    def fetch_blocking(uid)
      response = get("retrieve/#{uid}")
      return nil unless response.success?

      decode_response(JSON.parse(response.body, symbolize_names: true))
    end

    def fetch_nonblocking(uid)
      response = get("find/#{uid}")
      return nil unless response.success?

      decode_response(JSON.parse(response.body, symbolize_names: true))
    end

    def handle_error(error)
      raise WebFetch::ClientError, error
    end

    def no_request_error(uid)
      raise RequestNotFoundError, [I18n.t('no_request', uid: uid)]
    end

    def promises(requests)
      requests.map do |request|
        Promise.new(self, uid: request[:uid], request: request[:request])
      end
    end
  end
end
