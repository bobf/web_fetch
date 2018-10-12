# frozen_string_literal: true

module WebFetch
  # Retrieves a gathered HTTP request
  class Retriever
    include Validatable

    attr_reader :not_found_error

    def initialize(server, params, options)
      @uid = params[:uid]
      @hash = params[:hash]
      @server = server
      @block = options.fetch(:block, true)
    end

    def find
      request = @server.storage.fetch(@uid)
      return not_found if request.nil?
      return request.merge(pending: true) if pending?(request)

      request
    end

    private

    def validate
      error(:hash_or_uid_but_not_both) if !@uid.nil? && !@hash.nil?
      error(:missing_hash_and_uid) if @uid.nil? && @hash.nil?
    end

    def not_found
      @not_found_error = if !@uid.nil?
                           I18n.t(:uid_not_found)
                         elsif !@hash.nil?
                           I18n.t(:hash_not_found)
                         end
      nil
    end

    def pending?(request)
      return false if request.nil?
      return false if request[:succeeded]
      return false if request[:failed]
      # User requested blocking operation so we will wait until item is ready
      # rather than return a `pending` status
      return false if @block

      true
    end
  end
end
