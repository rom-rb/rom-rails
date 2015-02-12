require 'generators/rom'

module ROM
  module Generators
    class CommandsGenerator < Base
      def create_commands_file
        template(
          'create.rb.erb',
          File.join('app', 'commands', file_name, 'create.rb')
        )

        template(
          'update.rb.erb',
          File.join('app', 'commands', file_name, 'update.rb')
        )

        template(
          'delete.rb.erb',
          File.join('app', 'commands', file_name, 'delete.rb')
        )
      end
    end
  end
end
