require 'forwardable'

module WebFetch
  # EventMachine-friendly Logger
  class Logger
    extend SingleForwardable

    def self.log_path(path)
      @logger ||= EM::Logger.new(::Logger.new(log_file(path)))
    end

    def_delegators :@logger, :debug, :info, :warn, :error, :fatal

    class << self
      private

      def log_file(path)
        return STDOUT if STDOUT.isatty && path.nil?
        return File.open(File::NULL, 'w') if path.nil?
        log = File.open(path, 'a')
        log.sync = true # Prevent buffering
        log
      end
    end
  end
end
