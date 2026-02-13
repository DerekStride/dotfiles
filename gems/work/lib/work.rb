# frozen_string_literal: true

require "work/version"
require "work/log"
require "work/git"
require "work/tmux"
require "work/cli"

module Work
  class Error < StandardError; end
end
