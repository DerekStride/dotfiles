# frozen_string_literal: true

module Work
  module Tmux
    module_function

    def create_window(name, dir:, detached: true)
      cmd = ["tmux", "new-window", "-n", name, "-c", dir]
      cmd << "-d" if detached
      system(*cmd) || raise(Error, "Failed to create tmux window '#{name}'")
    end

    def select_window(name)
      system("tmux", "select-window", "-t", name) || raise(Error, "Failed to select window '#{name}'")
    end

    def send_keys(target, *commands)
      commands.each do |command|
        system("tmux", "send-keys", "-t", target, command, "Enter")
      end
    end

    def split_panes(target: nil)
      prefix = target ? "#{target}." : ""
      system("tmux", "split-window", "-h", "-t", "#{prefix}0", "-l", "50%", "-d")
      system("tmux", "split-window", "-v", "-t", "#{prefix}1", "-l", "50%", "-d")
    end

    def window_exists?(name)
      `tmux list-windows -F '\#{window_name}' 2>/dev/null`.lines.any? { _1.chomp == name }
    end
  end
end
