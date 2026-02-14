# frozen_string_literal: true

module Work
  module CLI
    class NewCommand < Base
      command_name "new"
      summary "Create a new tmux window"
      description "Create a new tmux window, optionally with a git worktree, setup, and split"
      @arguments = [["NAME", "Window/branch name (opens fzf if omitted)"]]
      examples(
        "work new my-feature",
        "work new -w my-feature    # with worktree + setup + split",
        "work new                  # opens fzf to select branch"
      )

      def define_flags(parser, options)
        parser.on("-w", "--worktree", "Create git worktree + setup + split") { options[:worktree] = true }
        super
      end

      def validate
        if options[:worktree] && !Work::Git.in_git_repo?
          logger.error("Not in a git repository (required for --worktree)")
          exit(1)
        end
      end

      def execute
        name = argv.shift || select_branch
        return 0 unless name

        if options[:worktree]
          worktree_workspace(name)
        else
          plain_window(name)
        end
      end

      private

      def select_branch
        unless Work::Git.in_git_repo?
          logger.error("Provide a name or run from a git repo")
          return nil
        end

        branches = Work::Git.local_branches
        if branches.empty?
          logger.error("No branches found")
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

      def plain_window(name)
        if Work::Tmux.window_exists?(name)
          Work::Tmux.select_window(name)
        else
          Work::Tmux.create_window(name, dir: Dir.pwd, detached: false)
        end
        0
      end

      def worktree_workspace(name)
        if Work::Git.world_monorepo?
          return world_workspace(name)
        end

        worktree_path = existing_worktree_path(name)

        # Worktree + window exist → switch
        if worktree_path && Work::Tmux.window_exists?(name)
          Work::Tmux.select_window(name)
          return 0
        end

        # Worktree exists, no window → create window + split
        if worktree_path
          Work::Tmux.create_window(name, dir: worktree_path)
          Work::Tmux.send_keys(name, "work split -t #{name}")
          return 0
        end

        # No worktree → create everything
        path = Work::Git.create_worktree(name)
        Work::Tmux.create_window(name, dir: path)
        chain = [setup_command(path), "work split -t #{name}"].compact.join(" && ")
        Work::Tmux.send_keys(name, chain)
        0
      end

      def existing_worktree_path(name)
        path = "#{Work::Git.git_root}.#{name}"
        Dir.exist?(path) ? path : nil
      end

      def world_workspace(name)
        if Work::Tmux.window_exists?(name)
          Work::Tmux.select_window(name)
          return 0
        end

        project = File.basename(Dir.pwd)
        Work::Tmux.create_window(name, dir: Dir.pwd)
        chain = "dev cd #{project} -t #{name} && work split -t #{name}"
        Work::Tmux.send_keys(name, chain)
        0
      end

      def setup_command(dir)
        if File.exist?("/opt/dev/bin/dev")
          "dev up"
        elsif File.exist?(File.join(dir, "Gemfile"))
          "bundle install"
        end
      end
    end
  end
end
