module WebFetch
  # Retrieves a gathered HTTP request
  class Retriever
    include Validatable

    attr_reader :not_found_error

    def initialize(server, params)
      @uid = params[:uid]
      @hash = params[:hash]
      @server = server
    end

    def find
      stored = @server.storage.fetch(@uid)
      return not_found if stored.nil?
      stored
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
  end
end
