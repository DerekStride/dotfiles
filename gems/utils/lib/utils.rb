# frozen_string_literal: true

require "utils/version"

require "utils/logger"
require "utils/debugger"
require "utils/timestamp"
require "utils/option_parser"
require "utils/canonical_logging"

module Utils
  class Error < StandardError; end
end
