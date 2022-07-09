# frozen_string_literal: true

module Utils
  module Timestamp
    module Millisecond
      def timestamp
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
      end

      def timestamp_units
        'ms'
      end
    end

    module Microsecond
      def timestamp
        Process.clock_gettime(Process::CLOCK_MONOTONIC, :microsecond)
      end

      def timestamp_units
        'us'
      end
    end

    OPTIONS = {
      "microsecond" => Microsecond,
      "millisecond" => Millisecond,
    }
    ALIASES = {
      "micro" => "microsecond",
      "micros" => "microsecond",
      "milli" => "millisecond",
      "millis" => "millisecond",
    }
  end
end

include Utils::Timestamp::OPTIONS.values.first
