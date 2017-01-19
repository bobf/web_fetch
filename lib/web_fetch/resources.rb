module WebFetch
  # Glue between the router and the guts of the application; calls the relevant
  # code and builds responses
  class Resources
    class << self
      def root(_server, _params)
        { status: status(:ok), payload: { application: 'WebFetch' } }
      end

      def gather(server, params)
        gatherer = Gatherer.new(server, params)
        if gatherer.valid?
          { status: status(:ok), payload: gatherer.start }
        else
          { status: status(:unprocessable),
            payload: { error: gatherer.errors } }
        end
      end

      def retrieve(server, params)
        retriever = Retriever.new(server, params)
        return { status: status(:unprocessable),
                 payload: { error: retriever.errors } } unless retriever.valid?
        defer_if_found(retriever)
      end

      private

      def status(name)
        { ok: 200,
          unprocessable: 422,
          not_found: 404 }
          .fetch(name)
      end

      def defer_if_found(retriever)
        found = retriever.find
        if found.nil?
          { status: status(:not_found),
            payload: { error: retriever.not_found_error } }
        else
          { deferred: found }
        end
      end
    end
  end
end
