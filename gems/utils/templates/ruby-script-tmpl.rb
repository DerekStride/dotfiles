#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem "utils", path: "#{ENV["ZSH"]}/gems/utils"
  gem 'pry-byebug'
  gem 'oj'
end

options = Utils::OptionParser.parse do |o|
  o.banner = "usage: ruby script.rb [options]"
end

log = Utils::Logger.instance
log.debug("Options parsed: #{options}")

def main(options)
  puts Oj.dump(options)
end

start = timestamp
main(options)
finished = timestamp

log.info("Finished in: #{finished - start}#{timestamp_units}")
