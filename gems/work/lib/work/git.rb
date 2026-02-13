# frozen_string_literal: true

module Work
  module Git
    WORLD_DIR = File.expand_path("~/world")

    module_function

    def in_git_repo?
      system("git", "rev-parse", "--git-dir", out: File::NULL, err: File::NULL)
    end

    def git_root
      @git_root ||= `git rev-parse --show-toplevel 2>/dev/null`.chomp
    end

    def world_monorepo?
      git_root.start_with?(WORLD_DIR)
    end

    def worktree_list
      `git worktree list --porcelain 2>/dev/null`
        .lines
        .grep(/^worktree /)
        .map { _1.sub(/^worktree /, "").chomp }
    end

    def create_worktree(name)
      worktree_path = "#{git_root}.#{name}"

      if system("git", "rev-parse", "--verify", name, out: File::NULL, err: File::NULL)
        system("git", "worktree", "add", worktree_path, name) || raise(Error, "Failed to create worktree")
      else
        system("git", "worktree", "add", "-b", name, worktree_path) || raise(Error, "Failed to create worktree")
      end

      worktree_path
    end

    def tmux_window_name
      return nil unless ENV["TMUX"]

      `tmux display-message -p '#W'`.chomp
    end

    def reset!
      @git_root = nil
    end
  end
end
