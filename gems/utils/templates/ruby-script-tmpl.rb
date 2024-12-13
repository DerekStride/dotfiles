#!/usr/bin/env ruby

require "bundler/inline"
require "optparse"
require "logger"
require "json"

$stdout.sync = $stderr.sync = true
def level = ENV.fetch("LOG_LEVEL", Logger::WARN)
def progname = File.basename($0)
def logger = @logger ||= Logger.new($stderr, level:, progname:)
def options = @options ||= {}

gemfile do
  source 'https://rubygems.org'

  gem "debug"
end

OptionParser.new do |o|
  o.banner = "usage: ruby #{progname} [options]"
  o.on("-v", "--verbose", "Enable verbose logging") do |verbose|
    logger.level -= 1 unless logger.debug?
    logger.level
  end
end.parse!(ARGV, into: options)

logger.debug("options=#{options}")

def main
  puts JSON.dump(options)
end

main
