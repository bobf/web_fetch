module WebFetch
  # Handles requests to gather URLs and delegates to the EventMachine web
  # server
  class Gatherer
    include Validatable

    HASHABLE_KEYS = [:url, :query_string, :headers, :method].freeze

    def initialize(params)
      @requests = params[:requests]
      @server = params[:_server]
    end

    def start
      tagged = { requests: tag_requests }
      @server.gather(tagged[:requests])
      tagged
    end

    private

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
  end
end
