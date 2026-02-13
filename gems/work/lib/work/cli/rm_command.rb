# frozen_string_literal: true

module Work
  module CLI
    class RmCommand < Base
      command_name "rm"
      aliases "remove"
      summary "Remove worktree + tmux window + branch"
      description "Delete a workspace: kills the tmux window, removes the git worktree, and deletes the branch"
      @arguments = [["NAME", "Branch/worktree name (opens fzf if omitted)"]]
      examples(
        "work rm my-feature",
        "work rm                   # opens fzf to select"
      )

      def validate
        unless Work::Git.in_git_repo?
          logger.error("Not in a git repository")
          exit(1)
        end
      end

      def execute
        names = argv.empty? ? Work::Workspace.select(multi: true) : argv
        return 0 if names.empty?

        errors = 0
        names.each do |name|
          puts "Removing #{name}..."
          errors += Work::Workspace.remove(name)
        end

        errors > 0 ? 1 : 0
      end
    end
  end
end
