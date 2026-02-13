# frozen_string_literal: true

require_relative "new_command"
require_relative "rm_command"
require_relative "split_command"

module Work
  module CLI
    class RootCommand < Base
      command_name "work"
      summary "Unified workspace tool for tmux + git worktrees"
      description "Unified workspace tool for tmux + git worktrees"
      examples(
        "work new my-feature",
        "work split",
        "work split -t my-feature"
      )

      register_subcommand NewCommand, category: :core
      register_subcommand RmCommand, category: :core
      register_subcommand SplitCommand, category: :core

      def define_flags(parser, options)
        super
      end
    end
  end
end
