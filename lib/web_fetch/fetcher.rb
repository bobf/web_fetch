module WebFetch
  class Fetcher
    include Validatable
    
    HASHABLE_KEYS = [:url]

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
      error(:requests_missing) if @requests.nil?
      error(:requests_not_array) if (!@requests.nil? &&
                                     !@requests.is_a?(Array))
      error(:requests_empty) if (@requests.is_a?(Array) &&
                                 @requests.length == 0)
      error(:missing_url) if (@requests.is_a?(Array) &&
                              @requests.any? { |req| req[:url].nil? })
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
