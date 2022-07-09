#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'pry-byebug'
  gem 'oj'
  gem 'terminal-table'
  gem "utils", path: "#{ENV["ZSH"]}/gems/utils"
end

require 'optparse'
require 'open3'

options = {}

OptionParser.new do |o|
  o.banner = "Usage: ruby script.rb [options]"

  o.on("-h", "--help") { puts(o); exit(0) }
  Utils::Logger.optparse(o)
  Utils::Timestamp.optparse(o)
end.parse!(into: options)

log = Utils::Logger.instance
log.debug("Options parsed: #{options}")

def main(options)
  puts Oj.dump({ "fizz" => "buzz", "foo" => { "bar" => "baz" } })
end

start = timestamp
main(options.except(:verbose, :timestamp))
finished = timestamp

log.info("Finished in: #{finished - start}#{timestamp_units}")
