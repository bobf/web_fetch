module WebFetch
  # EventMachine layer-specific helpers
  module EventMachineHelpers
    def wait_for_response(deferred, response)
      deferred[:http].callback do
        Logger.debug("HTTP fetch complete for uid: #{deferred[:uid]}")
        deferred[:succeeded] = true
      end

      deferred[:http].errback do
        Logger.debug("HTTP fetch failed for uid: #{deferred[:uid]}")
        deferred[:failed] = true
      end

      tick_loop(deferred, response)
    end

    def tick_loop(deferred, response)
      # XXX There may be a much nicer way to wait for an async task to complete
      # before returning a response but I couldn't figure it out, so I used
      # EM.tick_loop which effectively does the same as a Twisted deferred
      # callback chain, just much more explicitly.
      EM.tick_loop do
        if deferred[:succeeded]
          succeed(deferred, response)
          :stop
        elsif deferred[:failed]
          fail_(deferred, response)
          :stop
        end
      end
    end
  end
end
