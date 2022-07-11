# frozen_string_literal: true

module Utils
  module CanonicalLogging
    class LogDevice
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
  end
end
