# frozen_string_literal: true

require "pry-byebug"

module Utils
  module Debugger
    def self.included(base)
      Pry.config.output = IO.console unless $stdout.tty?
      Pry.config.input.input = IO.console unless $stdin.tty?
    end
  end
end

include Utils::Debugger
