#!/usr/bin/env ruby

require "bundler/inline"
require "logger"
require "json"

$stdout.sync = $stderr.sync = true
def progname = File.basename($0)
def options = @options ||= {}
def logger = @logger ||= Logger.new($stderr, progname:, level: ENV.fetch("LOG_LEVEL", Logger::WARN))
def check_exists!(file) = file.exist? ? file : logger.error("File not found: #{file}") && exit(Errno::ENOENT::Errno)

gemfile do
  source 'https://rubygems.org'

  gem "optparse-pathname"
  gem "debug"
end

OptionParser.new do |o|
  o.banner = "usage: ruby #{progname} [options]"
  o.on("-v", "--verbose", "Enable verbose logging") { logger.level -= 1 }
  o.on("-f", "--file FILE", Pathname, "A file to process") { check_exists!(_1) }
end.parse!(ARGV, into: options)

logger.debug("options=#{options}")

def main
  puts JSON.dump(options)
end

main
