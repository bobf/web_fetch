# frozen_string_literal: true

module WebFetch
  class Result
    attr_reader :body, :headers, :status, :error, :uid, :response_time

    def initialize(options = {})
      @pending = options.fetch(:pending, false)
      return if pending?

      @body = options.fetch(:body)
      @headers = options.fetch(:headers)
      @status = options.fetch(:status)
      @success = options.fetch(:success)
      @error = options.fetch(:error)
      @uid = options.fetch(:uid)
      @response_time = options.fetch(:response_time)
    end

    def pending?
      return false if @pending.nil?

      @pending
    end

    def complete?
      !pending?
    end

    def success?
      @success
    end
  end
end
