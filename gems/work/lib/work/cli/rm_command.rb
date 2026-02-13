# frozen_string_literal: true

module Work
  module CLI
    class RmCommand < Base
      command_name "rm"
      summary "Remove worktree + tmux window + branch"
      description "Delete a workspace: kills the tmux window, removes the git worktree, and deletes the branch"
      @arguments = [["NAME", "Branch/worktree name to remove"]]
      examples(
        "work rm my-feature"
      )

      def validate
        unless Work::Git.in_git_repo?
          logger.error("Not in a git repository")
          exit(1)
        end
      end

      def execute
        name = argv.shift
        unless name
          logger.error("Branch name is required")
          return 1
        end

        Work::Tmux.kill_window(name)
        Work::Git.remove_worktree(name)
        Work::Git.delete_branch(name)

        logger.info("Removed workspace '#{name}'")
        0
      end
    end
  end
end
