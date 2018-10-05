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

      block = options.fetch(:wait, true)
      @raw_result = find_or_retrieve(block)
      (@result = build_result)
    end

    def custom
      request&.custom
    end

    def complete?
      return false if @result.nil?
      return false if pending?
      return true if @result

      false
    end

    def pending?
      return false if @result.nil?

      @result == :pending
    end

    def success?
      complete? && @raw_result[:response][:success]
    end

    def error
      return nil unless complete?

      @raw_result[:response][:error]
    end

    private

    def find_or_retrieve(block)
      block ? @client.retrieve_by_uid(@uid) : @client.find_by_uid(@uid)
    end

    def build_result
      return nil if @raw_result.nil?
      return :pending if @raw_result[:pending]
      return nil unless @raw_result[:response]

      response = @raw_result[:response]
      new_result(response)
    end

    def new_result(response)
      Result.new(
        body: response[:body],
        headers: response[:headers],
        status: response[:status],
        success: @raw_result[:response][:success],
        error: @raw_result[:response][:error],
        uid: @uid
      )
    end
  end
end
