module WebFetch
  class Resources
    def self.root(params)
      [:ok, 'WebFetch']
    end

    def self.fetch(params)
      fetcher = Fetcher.new(params)
      return [status(:unprocessable), fetcher.errors] unless fetcher.valid?
      fetcher.start
      [status(:ok), 'Processing']
    end

    class << self
      def status(name)
        { ok: 200,
          unprocessable: 422 }
        .fetch(name)
      end
    end
  end
end
