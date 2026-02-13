# frozen_string_literal: true

module Work
  module CLI
    class SplitCommand < Base
      command_name "split"
      summary "Split window into 2 panes"
      description "Split a tmux window into 2 vertical panes (left and right)"
      examples(
        "work split",
        "work split -t my-feature"
      )

      def define_flags(parser, options)
        parser.on("-t", "--target NAME", "Target window name") { |v| options[:target] = v }
        super
      end

      def execute
        Work::Tmux.split_panes(**options.slice(:target))
        0
      end
    end
  end
end
