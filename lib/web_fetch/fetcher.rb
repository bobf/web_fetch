module WebFetch
  class Fetcher
    attr_reader :errors

    def initialize(options = {})
      @urls = options[:urls]
      validate
    end

    def valid?
      @errors.empty? && !errors.nil?
    end

    private

    def validate
      @errors = []

      error(:urls_missing) if @urls.nil?
      error(:urls_not_array) if !@urls.nil? && !@urls.is_a?(Array)
      error(:urls_empty) if @urls.is_a?(Array) && @urls.length == 0
    end

    def error(name)
      @errors.push(I18n.t(name))
    end
  end
end
