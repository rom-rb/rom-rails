require 'generators/rom'

module ROM
  module Generators
    class CommandsGenerator < Base
      class_option :adapter, banner: "--adapter=adapter",
        desc: "specify an adapter to use"

      def create_create_command
        template 'create.rb.erb', command_file(:create)
      end

      def create_update_command
        template 'update.rb.erb', command_file(:update)
      end

      def create_delete_command
        template 'delete.rb.erb', command_file(:delete)
      end

    private

      def command_file(command)
        File.join('app', 'commands', file_name, "#{command}.rb")
      end

    end
  end
end
