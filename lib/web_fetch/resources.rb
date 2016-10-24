module WebFetch
  # Glue between the router and the guts of the application; calls the relevant
  # code and builds responses
  class Resources
    def self.root(_params)
      { status: status(:ok), payload: { application: 'WebFetch' } }
    end

    def self.gather(params)
      gatherer = Gatherer.new(params)
      if gatherer.valid?
        { status: status(:ok), payload: gatherer.start }
      else
        { status: status(:unprocessable), payload: { error: gatherer.errors } }
      end
    end

    def self.retrieve(params)
      retriever = Retriever.new(params)
      return { status: status(:unprocessable),
               payload: { error: retriever.errors } } unless retriever.valid?
      found = retriever.find
      if found.nil?
        { status: status(:not_found),
          payload: { error: retriever.not_found_error } }
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
