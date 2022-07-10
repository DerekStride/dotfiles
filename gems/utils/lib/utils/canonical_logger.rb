# frozen_string_literal: true

module Utils
  class CanonicalLogger < ::Logger
    attr_reader :logs

    class LogDev
      def initialize(logs)
        @logs = logs
      end

      def with_severity(severity)
        old_sev = @severity
        @severity = severity.downcase
        yield
      ensure
        @severity = old_sev
      end

      def write(message)
        if message.is_a?(Hash)
          @logs.merge!(message)
        else
          @logs[@severity] ||= []
          @logs[@severity] << message
        end
      end

      def close; end
      def reopen(log = nil); end
    end

    attr_reader :logs

    def initialize(*args, **kwargs)
      super(*args, **kwargs)
      @logs = {}
      @logdev = LogDev.new(@logs)
    end

    def add(severity, message = nil, progname = nil)
      @logdev.with_severity(format_severity(severity)) do
        super
      end
    end

    def format_message(sev, time, prog, msg)
      return super unless msg.is_a?(Hash)
      msg
    end

    def log(hash)
      @logs.merge!(hash)
    end
  end
end
