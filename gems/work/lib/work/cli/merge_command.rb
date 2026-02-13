# frozen_string_literal: true

module Work
  module CLI
    class MergeCommand < Base
      command_name "merge"
      summary "Merge branch and clean up workspace"
      description "Merge a branch into the current branch, then remove its worktree, tmux window, and branch"
      @arguments = [["NAME", "Branch to merge (opens fzf if omitted)"]]
      examples(
        "work merge my-feature"
      )

      def validate
        unless Work::Git.in_git_repo?
          logger.error("Not in a git repository")
          exit(1)
        end
      end

      def execute
        name = argv.shift || select_one
        return 1 unless name

        unless system("git", "merge", name)
          logger.error("Merge failed — resolve conflicts then run: work rm #{name}")
          return 1
        end

        puts "Removing #{name}..."
        errors = Work::Workspace.remove(name)
        errors > 0 ? 1 : 0
      end

      private

      def select_one
        Work::Workspace.select(multi: false).first
      end
    end
  end
end
