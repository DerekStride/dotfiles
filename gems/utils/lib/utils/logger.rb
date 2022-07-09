# frozen_string_literal: true

$stderr.sync = true

require 'logger'

module Utils
  module Logger
    def self.instance
      # DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
      @logger ||= ::Logger.new($stderr, level: ::Logger::WARN)
    end

    def self.optparse(o)
      o.on("-v", "--verbose") do
        instance.level -= 1 unless instance.debug?

        case instance.level
        when 0; "DEBUG"
        when 1; "INFO"
        when 2; "WARN"
        when 3; "ERROR"
        when 4; "FATAL"
        else raise Utils::Error, "unknown logger level=#{Logger.level}"
        end
      end
    end
  end
end
