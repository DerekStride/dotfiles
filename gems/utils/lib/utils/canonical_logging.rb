# frozen_string_literal: true

module Utils
  module CanonicalLogging
    # ruby script.rb 2> >(jq)
    def self.instance
      return @logger if defined?(@logger)
      # logger interface for slurping in hash entries
      @logger = CanonicalLogger.new(nil, level: ::Logger::WARN)
      at_exit { $stderr.puts Oj.dump(@logger.logs) }
      @logger
    end

    def logger
      Utils::CanonicalLogging.instance
    end
  end
end
