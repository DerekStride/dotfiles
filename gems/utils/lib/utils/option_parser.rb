# frozen_string_literal: true

require 'optparse'

module Utils
  class OptionParser
    class << self
      def parse(args = ARGV, into: {})
        custom_parser = new
        ::OptionParser.new do |parser|
          custom_parser.define_options(parser)
          yield parser if block_given?
          parser.parse!(args, into: into)
        end
        into
      end

      def list_help_text(alt, list)
        "#{alt} Available options are: #{list.join(", ")}."
      end
    end

    attr_reader :verbose, :timestamp, :extras

    def initialize
      @timestamp = Timestamp::OPTIONS.values.first
    end

    def define_options(parser)
      define_help_option(parser)
      define_logger_option(parser)
      define_timestamp_option(parser)
    end

    def define_help_option(parser)
      parser.on("-h", "--help") { puts(parser); exit }
    end

    def define_logger_option(parser)
      parser.on("-v", "--verbose") do
        Logger.instance.level -= 1 unless Logger.instance.debug?
        Logger.level
      end
    end

    def define_timestamp_option(parser)
      parser.accept(Timestamp) do |timestamp_string|
        Timestamp::OPTIONS.fetch(timestamp_string) do
          timestamp_string = timestamp_string + "s" unless timestamp_string.end_with?("s")
          timestamp_string = timestamp_string + "econd"
          Timestamp::OPTIONS.fetch(timestamp_string) { puts(parser); exit(1) }
        end
      end

      parser.on( "--timestamp TIMESTAMP", Timestamp, self.class.list_help_text(
        "use TIMESTAMP instead of `#{Timestamp::OPTIONS.keys.first}` for timestamp resolution.",
        Timestamp::OPTIONS.keys,
      )) do |timestamp_module|
        Object.include(timestamp_module)
        timestamp_module
      end
    end
  end
end
