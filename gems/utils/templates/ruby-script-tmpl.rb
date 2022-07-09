#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'pry-byebug'
  gem 'oj'
  gem 'fiber_scheduler'
  gem 'terminal-table'
  gem "utils", path: "#{ENV["ZSH"]}/gems/utils"
end

require 'optparse'
require 'logger'
require 'open3'
require 'json'

$stderr.sync = true
# DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
$log = Logger.new($stderr, level: Logger::WARN)

$options = {}

OptionParser.new do |o|
  o.banner = "Usage: ruby script.rb [options]"

  o.on("-h", "--help") { puts(o); exit(0) }
  o.on("-v", "--verbose") { $log.level -= 1 unless $log.debug? }
  Utils::Timestamp.optparse(o)
end.parse!(into: $options)

def main
  binding.pry
  nil
end

start = timestamp
main
finished = timestamp

$log.info("Finished in: #{finished - start}#{timestamp_units}")
