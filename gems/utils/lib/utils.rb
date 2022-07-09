# frozen_string_literal: true

require "utils/version"
require "utils/optparse"
require "utils/timestamp"

include Utils::Timestamp::OPTIONS.values.first

module Utils
  class Error < StandardError; end
end
