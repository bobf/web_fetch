# frozen_string_literal: true

module WebFetch
  class Result
    attr_reader :body, :headers, :status

    def initialize(options = {})
      @pending = options.fetch(:pending, false)
      return if pending?

      @body = options.fetch(:body)
      @headers = options.fetch(:headers)
      @status = options.fetch(:status)
    end

    def pending?
      @pending
    end

    def complete?
      !pending?
    end
  end
end
