# frozen_string_literal: true

module Utils
  module Timestamp
    def self.optparse(o)
      o.accept(Utils::Timestamp) do |timestamp_string|
        Utils::Timestamp::OPTIONS.fetch(timestamp_string) do
          timestamp_string = timestamp_string + "s" unless timestamp_string.end_with?("s")
          timestamp_string = timestamp_string + "econd"
          Utils::Timestamp::OPTIONS.fetch(timestamp_string) do
            puts(o); exit(1)
          end
        end
      end

      o.on( "--timestamp TIMESTAMP", Timestamp, Utils::Optparse.list_help_text(
        "use TIMESTAMP instead of `#{OPTIONS.keys.first}` for timestamp resolution.",
        OPTIONS.keys,
      )) do |timestamp_module|
        Object.include(timestamp_module)
        timestamp_module
      end
    end

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
  end
end
