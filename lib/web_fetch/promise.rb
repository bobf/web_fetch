# frozen_string_literal: true

module WebFetch
  class Promise
    attr_reader :uid, :request, :response

    def initialize(client, options = {})
      @client = client
      @uid = options.fetch(:uid)
      @request = Request.from_hash(options.fetch(:request))
    end

    def fetch(options = {})
      return @response if complete?

      wait = options.fetch(:wait, true)
      @response = @client.fetch(@uid, wait: wait)
    end

    def custom
      request&.custom
    end

    def complete?
      return false if @response.nil?

      @response.complete?
    end

    def pending?
      return false if @response.nil?

      @response.pending?
    end

    def success?
      complete? && @response.success?
    end

    def error
      return nil unless complete?

      @response.error
    end
  end
end
