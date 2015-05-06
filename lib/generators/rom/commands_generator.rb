require 'generators/rom'

module ROM
  module Generators
    class CommandsGenerator < Base
      class_option :adapter,
        banner: "--adapter=adapter",
        desc: "specify an adapter to use", required: true,
        default: ROM.adapters.keys.first

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
        File.join('app', 'commands', command_dir, "#{command}.rb")
      end

      def command_dir
        "#{class_name.downcase.singularize}_commands"
      end

      def relation
        class_name.pluralize.underscore
      end

      def model_name
        class_name.singularize
      end

      def adapter
        options[:adapter]
      end
    end
  end
end
