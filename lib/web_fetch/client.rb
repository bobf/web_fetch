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

      outcome = block ? retrieve_by_uid(uid) : find_by_uid(uid)
      no_request_error(uid) if outcome.nil?

      return :pending if outcome[:pending]

      new_result(outcome)
    end

    def retrieve_by_uid(uid)
      response = get("retrieve/#{uid}")
      return nil unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def find_by_uid(uid)
      response = get("find/#{uid}")
      return nil unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    class << self
      def spawn(host, port, options)
        process = build_process(host, port, options)
        process.cwd = File.join(File.dirname(__dir__), '..')
        process.io.inherit!
        process.start
        process
      end

      private

      def build_process(host, port, options)
        command = options.fetch(:start_command, standard_start_command)
        args = ['--host', host, '--port', port.to_s]
        args += ['--log', options[:log]] unless options[:log].nil?
        args.push('--daemonize') if options[:daemonize]
        ChildProcess.build(*command, *args)
      end

      def standard_start_command
        %w[bundle exec ./bin/web_fetch_control run --]
      end
    end

    private

    def handle_error(error)
      raise WebFetch::ClientError, error
    end

    def no_request_error(uid)
      raise RequestNotFoundError, [I18n.t('no_request', uid: uid)]
    end

    def new_result(outcome)
      response = outcome[:response]
      Result.new(
        body: response[:body],
        headers: response[:headers],
        status: response[:status],
        success: response[:success],
        error: response[:error],
        uid: outcome[:uid]
      )
    end

    def promises(requests)
      requests.map do |request|
        Promise.new(self, uid: request[:uid], request: request[:request])
      end
    end
  end
end
