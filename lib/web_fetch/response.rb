module WebFetch
  class Response
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
      return false if @result.pending?
      return true if @result

      false
    end

    def pending?
      return false if @result.nil?
      @result.pending?
    end

    def success?
      complete? && @raw_result[:response][:success]
    end

    private

    def find_or_retrieve(block)
      block ? @client.retrieve_by_uid(@uid) : @client.find_by_uid(@uid)
    end

    def build_result
      return nil if @raw_result.nil?
      return nil unless @raw_result[:response] || @raw_result[:pending]
      return Result.new(pending: true) if @raw_result[:pending]
      response = @raw_result[:response]
      Result.new(
        body: response[:body],
        headers: response[:headers],
        status: response[:status]
      )
    end
  end
end
