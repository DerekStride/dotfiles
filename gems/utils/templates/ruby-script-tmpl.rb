#!/usr/bin/env ruby

require "bundler/inline"
require "optparse"
require "logger"
require "json"

PROGNAME = File.basename($0)

def logger
  @logger ||= Logger.new($stderr, level: ENV.fetch("LOG_LEVEL", Logger::WARN), progname: PROGNAME)
end

gemfile do
  source 'https://rubygems.org'

  gem "debug"
end

$options = {}

OptionParser.new do |o|
  o.banner = "usage: ruby #{PROGNAME} [options]"
  o.on("-v", "--verbose", "Enable verbose logging") do |verbose|
    logger.level -= 1 unless logger.debug?
    logger.level
  end
end.parse!(ARGV, into: $options)

logger.debug("options=#{$options}")

def main
  puts JSON.dump($options)
end

main
