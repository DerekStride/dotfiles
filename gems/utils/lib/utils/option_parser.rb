# frozen_string_literal: true

require 'optparse'

module Utils
  class OptionParser
    class << self
      def parse(args = ARGV, into: {})
        custom_parser = new
        ::OptionParser.new do |parser|
          if block_given?
            parser.separator ""
            yield parser
          end
          custom_parser.define_options(parser)
          parser.parse!(args, into: into)
        end
        into
      end

      def list_help_text(list)
        "Available options are: #{list.join(", ")}."
      end
    end

    attr_reader :verbose, :timestamp, :extras

    def initialize
      @timestamp = Timestamp::OPTIONS.values.first
    end

    def define_options(parser)
      parser.separator ""
      parser.separator "Common options:"
      define_help_option(parser)
      define_logger_option(parser)
      define_timestamp_option(parser)
    end

    def define_help_option(parser)
      parser.on_tail("-h", "--help") { puts(parser); exit }
    end

    def define_logger_option(parser)
      parser.on_tail("-v", "--verbose") do
        Logger.instance.level -= 1 unless Logger.instance.debug?
        Logger.level
      end
    end

    def define_timestamp_option(parser)
      parser.on_tail(
        "--timestamp TIMESTAMP",
        Timestamp::OPTIONS.keys,
        Timestamp::ALIASES,
        "use TIMESTAMP instead of `#{Timestamp::OPTIONS.keys.first}` for timestamp resolution.",
        self.class.list_help_text(Timestamp::OPTIONS.keys),
      ) do |timestamp_string|
        timestamp_module = Timestamp::OPTIONS[timestamp_string]
        Object.include(timestamp_module)
        timestamp_module
      end
    end
  end
end
