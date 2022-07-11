# frozen_string_literal: true

module Utils
  module CanonicalLogging
    class Formatter
      def initialize(formatter)
        @formatter = formatter
      end

      def call(severity, time, progname, msg)
        return msg if msg.is_a?(Hash)
        @formatter.call(severity, time, progname, msg)
      end
    end
  end
end
