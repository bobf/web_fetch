module WebFetch
  class Resources
    def self.root(params)
      { status: status(:ok), payload: 'WebFetch' }
    end

    def self.fetch(params)
      fetcher = Fetcher.new(params)
      if fetcher.valid?
        { status: status(:ok), payload: JSON.dump(fetcher.start) }
      else
        { status: status(:unprocessable), payload: JSON.dump(fetcher.errors) }
      end
    end

    def self.retrieve(params)
      retriever = Retriever.new(params)
      return { status: status(:unprocessable),
               payload: retriever.errors } unless retriever.valid?
      found = retriever.find
      if found.nil?
        { status: status(:not_found),
          payload: JSON.dump(error: retriever.not_found_error) }
      else
        { deferred: found }
      end
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
