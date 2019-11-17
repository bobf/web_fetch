# frozen_string_literal: true

module WebFetch
  # Handles requests to gather URLs and delegates to the EventMachine web
  # server
  class Gatherer
    include Validatable

    HASHABLE_KEYS = %i[url query_string headers method].freeze

    def initialize(storage, params, logger = Logger, http = EM::HttpRequest)
      @requests = params[:requests]
      @storage = storage
      @logger = logger
      @http = http
    end

    def start
      tagged = { requests: tag_requests }
      gather(tagged[:requests])
      tagged
    end

    private

    def gather(targets)
      targets.each do |target|
        uid = target[:uid]
        @logger.debug("Initialising async for uid: #{uid}")
        deferred = request_async(target)
        request = { uid: uid, start_time: target[:start_time],
                    request: target[:request] }
        apply_callbacks(request, deferred)
      end
    end

    def apply_callbacks(request, deferred)
      uid = request[:uid]
      deferred.callback do
        @logger.debug("HTTP fetch successful for uid: #{uid}")
        @storage.store(uid, response(request, deferred, success: true))
      end

      deferred.errback do
        @logger.debug("HTTP fetch failure for uid: #{uid}")
        @storage.store(uid, response(request, deferred, success: false))
      end

      @logger.debug("HTTP fetch started for uid: #{uid}")
    end

    def request_async(target)
      request = target[:request]
      target[:start_time] = Time.now.utc
      async_request = @http.new(request[:url])
      method = request.fetch(:method, 'GET').downcase.to_sym
      async_request.public_send(
        method, head: request[:headers],
                query: request.fetch(:query, {}),
                body: request.fetch(:body, nil)
      )
    end

    def validate
      error(:requests_missing) if requests_missing?
      error(:requests_not_array) if requests_not_array?
      error(:requests_empty) if requests_empty?
      error(:missing_url) if missing_url?
    end

    def requests_missing?
      @requests.nil?
    end

    def requests_not_array?
      !@requests.nil? && !@requests.is_a?(Array)
    end

    def requests_empty?
      @requests.is_a?(Array) && @requests.length.zero?
    end

    def missing_url?
      @requests.is_a?(Array) && @requests.any? { |req| req[:url].nil? }
    end

    def tag_requests
      @requests.map do |request|
        { request: request, hash: hash(request), uid: uid }
      end
    end

    def hash(obj)
      string = JSON.dump(obj.select { |key| HASHABLE_KEYS.include?(key) })
      Digest.hexencode(Digest::SHA1.new.digest(string))
    end

    def uid
      SecureRandom.uuid
    end

    def response_time(request)
      Time.now.utc - request[:start_time]
    end

    def response(request, result, options = {})
      {
        response: result(request, result, options.fetch(:success)),
        request: request,
        uid: request[:uid]
      }
    end

    def result(request, result, success)
      {
        success: success,
        body: Base64.encode64(result.response),
        headers: result.headers,
        status: result.response_header.status,
        response_time: response_time(request)
      }.merge(success ? {} : { error: (result.error&.inspect) })
    end
  end
end
