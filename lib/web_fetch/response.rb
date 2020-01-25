# frozen_string_literal: true

module WebFetch
  class Response
    attr_reader :request, :body, :headers, :status, :error, :uid, :response_time

    def initialize(response)
      @pending = response.fetch(:pending, false)
      return if pending?

      outcome = response.fetch(:request)
      remote_request = outcome.fetch(:request)
      remote_response = outcome.fetch(:response)
      @uid = outcome.fetch(:uid)
      @response_time = remote_response.fetch(:response_time, nil)
      @request = Request.from_hash(remote_request[:request], validate: false)
      initialize_response(outcome.fetch(:response))
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

    private

    def initialize_response(response)
      @body = Base64.decode64(response.fetch(:body))
      @headers = response.fetch(:headers)
      @status = response.fetch(:status)
      @success = response.fetch(:success)
      @error = response.fetch(:error, nil)
    end
  end
end
