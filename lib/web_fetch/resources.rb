module WebFetch
  class Resources
    def self.root(params)
      [status(:ok), 'WebFetch']
    end

    def self.fetch(params)
      fetcher = Fetcher.new(params)
      return [status(:unprocessable), fetcher.errors] unless fetcher.valid?
      fetcher.start
      [status(:ok), JSON.dump(fetcher.start)]
    end

    def self.retrieve(params)
      retriever = Retriever.new(params)
      return [status(:unprocessable), retriever.errors] unless retriever.valid?
      found = retriever.find
      if found.nil?
        return [status(:not_found),
                JSON.dump(error: retriever.not_found_error)]
      end
      [status(:ok), JSON.dump(found)]
    end

    class << self
      def status(name)
        { ok: 200,
          unprocessable: 422,
          not_found: 404 }
        .fetch(name)
      end
    end
  end
end
