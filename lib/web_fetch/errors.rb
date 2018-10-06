# frozen_string_literal: true

module WebFetch
  class Error < StandardError
    attr_reader :error

    def initialize(error)
      super
      @error = error
    end
  end

  class ClientError < Error; end

  class RequestNotFoundError < Error; end
end
