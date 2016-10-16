module WebFetch
  module Helpers
    def symbolize(obj)
      # >:)
      JSON.parse(JSON.dump(obj), symbolize_names: true)
    end
  end
end
