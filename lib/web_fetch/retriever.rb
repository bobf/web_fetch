# frozen_string_literal: true

module WebFetch
  # Retrieves a gathered HTTP request
  class Retriever
    include Validatable

    def initialize(storage, params, options)
      @uid = params[:uid]
      @hash = params[:hash]
      @storage = storage
      @block = options.fetch(:block, true)
    end

    def find
      request = @storage.fetch(@uid) unless @uid.nil?
      return pending if request.nil?

      request
    end

    private

    def validate
      error(:hash_or_uid_but_not_both) if !@uid.nil? && !@hash.nil?
      error(:missing_hash_and_uid) if @uid.nil? && @hash.nil?
    end

    def pending
      { uid: @uid, pending: true }
    end
  end
end
