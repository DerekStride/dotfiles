# frozen_string_literal: true

module Utils
  module Optparse
    extend self

    def list_help_text(alt, list)
      "#{alt} Available options are: #{list.join(", ")}."
    end
  end
end
