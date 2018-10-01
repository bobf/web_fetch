# frozen_string_literal: true

module WebFetch
  # EventMachine layer-specific helpers
  module EventMachineHelpers
    def request_async(request)
      async_request = EM::HttpRequest.new(request[:url])
      method = request.fetch(:method, 'GET').downcase.to_sym
      async_request.public_send(
        method,
        head: request[:headers],
        query: request.fetch(:query, {}),
        body: request.fetch(:body, nil)
      )
    end

    def apply_callbacks(request)
      request[:deferred].callback do
        Logger.debug("HTTP fetch complete for uid: #{request[:uid]}")
        request[:succeeded] = true
      end

      request[:deferred].errback do
        Logger.debug("HTTP fetch failed for uid: #{request[:uid]}")
        request[:failed] = true
      end
    end

    def wait_for_response(request, response)
      tick_loop(request, response)
    end

    def tick_loop(request, response)
      # XXX There may be a much nicer way to wait for an async task to complete
      # before returning a response but I couldn't figure it out, so I used
      # EM.tick_loop which effectively does the same as a Twisted deferred
      # callback chain, just much more explicitly.
      EM.tick_loop do
        if request[:succeeded]
          succeed(request, response)
          :stop
        elsif request[:failed]
          fail_(request, response)
          :stop
        end
      end
    end
  end
end
