# frozen_string_literal: true

require "utils/canonical_logging/logger"
require "utils/canonical_logging/formatter"
require "utils/canonical_logging/log_device"

module Utils
  module CanonicalLogging
    # ruby script.rb 2> >(jq)
    def self.instance
      return @logger if defined?(@logger)
      # logger interface for slurping in hash entries
      @logger = Utils::CanonicalLogging::Logger.new(nil, level: ::Logger::WARN)
      at_exit { $stderr.puts Oj.dump(@logger.logs) }
      @logger
    end

    def logger
      Utils::CanonicalLogging.instance
    end
  end
end
