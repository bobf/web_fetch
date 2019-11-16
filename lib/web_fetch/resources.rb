# frozen_string_literal: true

module WebFetch
  # Glue between the router and the guts of the application; calls the relevant
  # code and builds responses
  class Resources
    class << self
      def root(_server, _params)
        {
          status: status(:ok),
          command: 'root',
          payload: { application: 'WebFetch' }
        }
      end

      def gather(server, params)
        gatherer = Gatherer.new(server.storage, params)
        if gatherer.valid?
          { status: status(:ok), payload: gatherer.start, command: 'gather' }
        else
          { status: status(:unprocessable),
            payload: { error: gatherer.errors }, command: 'gather' }
        end
      end

      def retrieve(server, params, options = {})
        retriever = Retriever.new(server.storage, params, options)
        unless retriever.valid?
          return { status: status(:unprocessable), command: 'retrieve',
                   payload: { error: retriever.errors } }
        end
        defer_if_found(retriever)
      end

      def find(server, params)
        retrieve(server, params, block: false)
      end

      private

      def status(name)
        {
          ok: 200,
          unprocessable: 422
        }.fetch(name)
      end

      def defer_if_found(retriever)
        { command: 'retrieve', request: retriever.find }
      end
    end
  end
end
