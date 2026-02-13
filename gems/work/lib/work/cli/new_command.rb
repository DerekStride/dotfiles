# frozen_string_literal: true

module Work
  module CLI
    class NewCommand < Base
      command_name "new"
      summary "Create worktree + tmux window + setup + split"
      description "Create a git worktree, tmux window, run setup, and split panes"
      @arguments = [["NAME", "Branch/worktree name (defaults to current tmux window name)"]]
      examples(
        "work new my-feature",
        "work new                  # uses current tmux window name"
      )

      def validate
        unless Work::Git.in_git_repo?
          logger.error("Not in a git repository")
          exit(1)
        end
      end

      def execute
        name = resolve_name(argv.first)

        if Work::Tmux.window_exists?(name)
          logger.error("Window '#{name}' already exists")
          return 1
        end

        if Work::Git.world_monorepo?
          create_world_workspace(name)
        else
          create_worktree_workspace(name)
        end

        0
      end

      private

      def resolve_name(arg)
        name = arg || Work::Git.tmux_window_name
        unless name && !name.empty?
          logger.error("No name provided and not in a tmux window")
          exit(1)
        end
        name
      end

      def create_world_workspace(name)
        project = File.basename(Dir.pwd)
        Work::Tmux.create_window(name, dir: Dir.pwd)
        chain = "dev cd #{project} -t #{name} && work split -t #{name}"
        Work::Tmux.send_keys(name, chain)
        logger.info("Created world workspace '#{name}' for #{project}")
      end

      def create_worktree_workspace(name)
        worktree_path = Work::Git.create_worktree(name)
        Work::Tmux.create_window(name, dir: worktree_path)

        setup = setup_command(worktree_path)
        chain = [setup, "work split -t #{name}"].compact.join(" && ")
        Work::Tmux.send_keys(name, chain)
        logger.info("Created workspace '#{name}' at #{worktree_path}")
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
