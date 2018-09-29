# frozen_string_literal: true

module WebFetch
  # Shared code used throughout the application
  module Helpers
    def symbolize(obj)
      # >:)
      JSON.parse(JSON.dump(obj), symbolize_names: true)
    end
  end
end
