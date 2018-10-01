module WebFetch
  class Error < StandardError
    attr_reader :errors

    def initialize(errors = nil)
      @errors = errors
    end
  end

  class ClientError < Error; end

  class RequestNotFoundError < Error; end
end
