# frozen_string_literal: true

module Utils
  module CanonicalLogging
    class Formatter
      def initialize(formatter)
        @formatter = formatter
      end

      def call(severity, time, progname, msg)
        return deep_stringify_keys(msg) if msg.is_a?(Hash)
        @formatter.call(severity, time, progname, msg)
      end

      private

      def deep_stringify_keys(hash)
        return hash unless hash.is_a?(Hash)
        hash.each_with_object({}) do |(k, v), h|
          h[k.to_s] = deep_stringify_keys(v)
        end
      end
    end
  end
end
