module WebFetch
  class Response
    attr_reader :uid, :request, :result

    def initialize(client, options = {})
      @client = client
      @uid = options[:uid]
      @request = options[:request]
    end

    def fetch(options = {})
      return @result if complete?
      block = options.fetch(:wait, true)
      (@result = find_or_retrieve(block))
    end

    def complete?
      return false if @result.nil?
      return true if @result[:response]
      return false if @result[:pending]

      false
    end

    private

    def find_or_retrieve(block)
      block ? @client.retrieve_by_uid(@uid) : @client.find_by_uid(@uid)
    end
  end
end
