# frozen_string_literal: true

module Work
  module Workspace
    module_function

    def select(multi: false)
      branches = Work::Git.worktree_branches
      if branches.empty?
        $stderr.puts "No worktrees found"
        return []
      end

      args = ["fzf"]
      args << "--multi" if multi

      output = IO.popen(args, "r+") do |fzf|
        fzf.write(branches.join("\n"))
        fzf.close_write
        fzf.read
      end

      return [] unless $?.success?
      output.lines.map(&:chomp).reject(&:empty?)
    end

    def remove(name)
      errors = 0

      if Work::Tmux.window_exists?(name)
        Work::Tmux.kill_window(name)
        puts "  Killed tmux window"
      end

      begin
        Work::Git.remove_worktree(name)
        puts "  Removed worktree"
      rescue Work::Error => e
        $stderr.puts e.message
        errors += 1
      end

      begin
        result = Work::Git.delete_branch(name)
        puts "  #{result}"
      rescue Work::Error => e
        $stderr.puts e.message
        errors += 1
      end

      errors
    end
  end
end
