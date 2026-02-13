# frozen_string_literal: true

require "open3"

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

    def worktree_branches
      `git worktree list --porcelain 2>/dev/null`
        .split("\n\n")
        .filter_map do |block|
          lines = block.lines.map(&:chomp)
          path = lines.find { _1.start_with?("worktree ") }&.sub("worktree ", "")
          branch = lines.find { _1.start_with?("branch ") }&.sub("branch refs/heads/", "")
          next if path == git_root
          branch
        end
    end

    def remove_worktree(name)
      worktree_path = "#{git_root}.#{name}"
      _out, err, status = Open3.capture3("git", "worktree", "remove", worktree_path)
      return if status.success?
      raise Error, err.chomp.empty? ? "Failed to remove worktree '#{worktree_path}'" : err.chomp
    end

    def delete_branch(name)
      out, err, status = Open3.capture3("git", "branch", "-d", name)
      unless status.success?
        raise Error, err.chomp.empty? ? "Failed to delete branch '#{name}'" : err.chomp
      end
      out.chomp
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
