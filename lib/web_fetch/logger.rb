require 'forwardable'

module WebFetch
  class Logger
    extend SingleForwardable

    def self.set_log_path(path)
      @logger ||= EM::Logger.new(::Logger.new(log_file(path)))
    end

    def_delegators :@logger, :debug, :info, :warn, :error, :fatal

    class << self
      def log_file(path)
        return STDERR if path.nil?
        log = File.open(path, 'a')
        log.sync = true # Prevent buffering
        log
      end
    end
  end
end
