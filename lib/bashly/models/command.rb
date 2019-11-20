module Bashly
  module Models
    class Command < Base
      # Returns all the possible aliases for this command
      def aliases
        short ? [name, short] : [name]
      end

      # Returns an array of Arguments
      def args
        return [] unless options["args"]
        options["args"].map do |options|
          Argument.new options
        end
      end

      # Returns a string suitable to be a headline
      def caption_string
        help ? "#{full_name} - #{summary}" : full_name
      end

      # Returns only the names of the subcommands (Commands)
      def command_names
        commands.map &:name
      end

      # Returns an array of the subcommands (Commands)
      def commands
        return [] unless options["commands"]
        options["commands"].map do |options|
          options['parent_name'] = full_name
          command = Command.new options
        end
      end

      # Returns an array of Flags
      def flags
        return [] unless options["flags"]
        options["flags"].map do |options|
          Flag.new options
        end
      end

      # Returns the name of the command, including its parent name (in case
      # this is a subcommand)
      def full_name
        parent_name ? "#{parent_name} #{name}" : name
      end

      # Reads a file from the userspace (Settings.source_dir) and returns
      # its contents. 
      # If the file is not found, returns a string with a hint.
      def load_user_file(file)
        path = "#{Settings.source_dir}/#{file}"
        content = if File.exist? path
          File.read path
        else
          "# error: cannot load file"
        end
        "# :#{path}\n#{content}"
      end

      # Returns an array of all the required Arguments
      def required_args
        args.select &:required
      end

      # Returns an array of all the required Flags
      def required_flags
        flags.select &:required
      end

      # Returns the first line of the help message
      def summary
        return "" unless help
        help.split("\n").first
      end

      # Returns a constructed string suitable for Usage pattern
      def usage_string
        result = [full_name]
        result << "[command]" if commands.any?
        args.each do |arg|
          result << arg.usage_string
        end
        result << "[options]"
        result.join " "
      end

      def verify
        if commands.any?
          if args.any? or flags.any?
            raise ConfigurationError, "Error in the !txtgrn!#{full_name}!txtrst! command.\nThe !txtgrn!commands!txtrst! key cannot be at the same level as the !txtgrn!args!txtrst! or !txtgrn!flags!txtrst! keys."
          end

          if parent_name
            raise ConfigurationError, "Error in the !txtgrn!#{full_name}!txtrst! command.\nNested commands are not supported."
          end
        end
      end

    end
  end
end