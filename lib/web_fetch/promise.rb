# frozen_string_literal: true

module WebFetch
  class Promise
    attr_reader :uid, :request, :result

    def initialize(client, options = {})
      @client = client
      @uid = options[:uid]
      @request = Request.from_hash(options[:request])
    end

    def fetch(options = {})
      return @result if complete?

      wait = options.fetch(:wait, true)
      (@result = @client.fetch(@uid, wait: wait))
    end

    def custom
      request&.custom
    end

    def complete?
      return false if @result.nil?

      @result.complete?
    end

    def pending?
      return false if @result.nil?

      @result.pending?
    end

    def success?
      complete? && @result.success?
    end

    def error
      return nil unless complete?

      @result.error
    end
  end
end
