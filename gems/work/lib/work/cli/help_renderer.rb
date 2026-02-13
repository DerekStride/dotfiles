# frozen_string_literal: true

module Work
  module CLI
    class HelpRenderer
      def initialize(command)
        @command = command
      end

      def render
        sections = []
        sections << description_section
        sections << usage_section
        sections << arguments_section if arguments.any?
        sections << commands_section if subcommands.any?
        sections << flags_section
        sections << examples_section if examples.any?
        sections << learn_more_section
        sections.compact.join("\n\n") + "\n"
      end

      private

      def description_section
        @command.class.description
      end

      def usage_section
        suffix = if subcommands.any?
          "<command> [flags]"
        else
          "[flags]"
        end
        "USAGE\n  #{@command.full_command_name} #{suffix}"
      end

      def arguments_section
        lines = arguments.map { |name, desc| "  %-14s %s" % [name, desc] }
        "ARGUMENTS\n#{lines.join("\n")}"
      end

      def commands_section
        grouped = subcommands.group_by { |s| s[:category] }
        sections = []

        if grouped[:core]&.any?
          sections << format_command_group("CORE COMMANDS", grouped[:core])
        end

        additional = grouped.reject { |k, _| k == :core }
        additional.each do |category, entries|
          label = "#{category.to_s.upcase} COMMANDS"
          sections << format_command_group(label, entries)
        end

        sections.join("\n\n")
      end

      def format_command_group(heading, entries)
        lines = entries.map do |entry|
          klass = entry[:klass]
          names = [klass.command_name, *klass.aliases].join(", ")
          "  %-14s %s" % [names, klass.summary]
        end
        "#{heading}\n#{lines.join("\n")}"
      end

      def flags_section
        parser = @command.send(:build_option_parser)
        parser.on_tail("-h", "--help", "Show help for command")
        summary = parser.summarize.join
        return nil if summary.strip.empty?

        summary.rstrip
      end

      def examples_section
        lines = examples.map { |ex| "  $ #{ex}" }
        "EXAMPLES\n#{lines.join("\n")}"
      end

      def learn_more_section
        if subcommands.any?
          "LEARN MORE\n  Use '#{@command.full_command_name} <command> --help' for more information about a command."
        else
          "LEARN MORE\n  Use '#{@command.full_command_name} --help' for more information."
        end
      end

      def subcommands
        @command.class.registered_subcommands
      end

      def examples
        @command.class.examples
      end

      def arguments
        @command.class.instance_variable_get(:@arguments) || []
      end
    end
  end
end
