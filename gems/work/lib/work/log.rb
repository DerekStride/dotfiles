# frozen_string_literal: true

require "logger"

module Work
  module Log
    LOG_LEVELS = {
      "DEBUG" => ::Logger::DEBUG,
      "INFO" => ::Logger::INFO,
      "WARN" => ::Logger::WARN,
      "ERROR" => ::Logger::ERROR,
      "FATAL" => ::Logger::FATAL,
    }.freeze

    class << self
      attr_writer :logger

      def debug(message) = logger.debug(message)
      def info(message) = logger.info(message)
      def warn(message) = logger.warn(message)
      def error(message) = logger.error(message)
      def fatal(message) = logger.fatal(message)

      def logger
        @logger ||= create_logger
      end

      def reset!
        @logger = nil
      end

      private

      def create_logger
        ::Logger.new($stderr, progname: "work").tap do |l|
          l.level = LOG_LEVELS.fetch(log_level)
        end
      end

      def log_level
        level_str = (ENV["WORK_LOG_LEVEL"] || "WARN").upcase
        unless LOG_LEVELS.key?(level_str)
          raise ArgumentError, "Invalid log level: #{level_str}. Valid levels are: #{LOG_LEVELS.keys.join(", ")}"
        end

        level_str
      end
    end
  end
end
