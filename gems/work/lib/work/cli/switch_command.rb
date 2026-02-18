# frozen_string_literal: true

module Work
  module CLI
    class SwitchCommand < Base
      command_name "switch"
      summary "Switch to an existing worktree"
      description "Select an existing worktree via fzf and open its tmux window"
      @arguments = [["NAME", "Worktree branch name (opens fzf if omitted)"]]
      examples(
        "work switch",
        "work switch my-feature"
      )

      def validate
        unless Work::Git.in_git_repo?
          logger.error("Not in a git repository")
          exit(1)
        end
      end

      def execute
        name = argv.shift || select_worktree
        return 0 unless name

        worktree_path = Work::Git.worktree_path_for(name)
        unless worktree_path
          logger.error("No worktree for branch '#{name}'")
          return 1
        end

        if Work::Tmux.window_exists?(name)
          Work::Tmux.select_window(name)
        else
          Work::Tmux.create_window(name, dir: worktree_path, detached: false)
        end
        0
      end

      private

      def select_worktree
        branches = Work::Git.worktree_branches
        if branches.empty?
          logger.error("No worktrees found")
          return nil
        end

        output = IO.popen(["fzf"], "r+") do |fzf|
          fzf.write(branches.join("\n"))
          fzf.close_write
          fzf.read
        end

        return nil unless $?.success?
        result = output.chomp
        result.empty? ? nil : result
      end
    end
  end
end
