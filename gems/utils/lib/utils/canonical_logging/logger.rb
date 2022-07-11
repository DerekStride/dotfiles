# frozen_string_literal: true

module Utils
  module CanonicalLogging
    class Logger < ::Logger
      attr_reader :logs

      def initialize(*args, **kwargs)
        super(*args, **kwargs)
        @logs = {}
        @formatter = Formatter.new(@formatter || @default_formatter)
        @logdev = LogDevice.new(@logs)
      end

      def add(severity, message = nil, progname = nil)
        @logdev.with_severity(format_severity(severity)) do
          super
        end
      end
    end
  end
end
