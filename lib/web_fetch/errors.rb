# frozen_string_literal: true

module WebFetch
  class Error < StandardError; end

  class ClientError < Error; end

  class RequestNotFoundError < Error; end
end
