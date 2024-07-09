#!/usr/bin/env ruby

require "bundler/inline"
require "optparse"
require "json"

gemfile do
  source 'https://rubygems.org'

  gem "debug"
end

options = {}

OptionParser.new do |o|
  o.banner = "usage: ruby script.rb [options]"
end.parse!(ARGV, into: options)

def main(options)
  puts JSON.dump(options)
end

main(options)
