# frozen_string_literal: true

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
      unless retriever.valid?
        return { status: status(:unprocessable),
                 payload: { error: retriever.errors } }
      end
      found = retriever.find
      return not_found(retriever) if found.nil?

      { deferred: found }
    end

    class << self
      def status(name)
        {
          ok: 200,
          unprocessable: 422,
          not_found: 404
        }.fetch(name)
      end

      def not_found(retriever)
        {
          status: status(:not_found),
          payload: { error: retriever.not_found_error }
        }
      end
    end
  end
end
