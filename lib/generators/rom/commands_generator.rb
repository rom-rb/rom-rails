require 'generators/rom'

module ROM
  module Generators
    class CommandsGenerator < Base

      def create_commands_file
        template(
          'commands.rb.erb',
          File.join('app', 'commands', "#{file_name}.rb")
        )
      end

    end
  end
end
