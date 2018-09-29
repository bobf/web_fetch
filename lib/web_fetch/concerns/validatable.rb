# frozen_string_literal: true

module WebFetch
  # Provides boilerplate for a validatable model
  module Validatable
    attr_reader :errors

    def valid?
      @errors = []
      validate
      @errors.empty?
    end

    private

    def validate
      error = <<-MSG.gsub(/\s+/, ' ')
        Override and call `error(:i18n_key)` as many times as required for each
        validation failure.
        Supplementary text can be added to the error by passing as the second
        parameter to `error`
      MSG
      raise NotImplementedError, error
    end

    def error(name, aux = '')
      aux = ' ' + aux unless aux.empty?
      @errors.push(I18n.t(name) + aux)
    end
  end
end
