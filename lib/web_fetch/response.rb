module WebFetch
  class Response
    def initialize(client, options = {})
      @client = client
      @uid = options[:uid]
    end

    def fetch(options = {})
      block = options.fetch(:wait, true)
      block ? @client.retrieve_by_uid(@uid) : @client.find_by_uid(@uid)
    end
  end
end
