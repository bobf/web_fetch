# frozen_string_literal: true

module WebFetch
  class Response
    attr_reader :request, :body, :headers, :status, :error, :uid, :response_time

    def initialize(outcome)
      @pending = outcome.fetch(:pending, false)
      return if pending?

      @uid = outcome.fetch(:uid)
      @response_time = outcome.fetch(:response_time, nil)
      @request = Request.from_hash(outcome.fetch(:request))
      initialize_response(outcome.fetch(:response))
    end

    def initialize_response(response)
      @body = response.fetch(:body)
      @headers = response.fetch(:headers)
      @status = response.fetch(:status)
      @success = response.fetch(:success)
      @error = response.fetch(:error, nil)
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
