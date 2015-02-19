require 'generators/rom'

module ROM
  module Generators
    class FormGenerator < Base
      class_option :command,
        banner: "--command=command",
        desc: "specify command to use", required: true

      def create_command
        type = edit_or_new

        template "#{type}_form.rb.erb",
          File.join("app", "forms", "#{type}_#{file_name.singularize}_form.rb")
      end

      private

      def model_name
        class_name.singularize.camelcase
      end

      def relation
        class_name.pluralize.underscore
      end

      def edit_or_new
        case options[:command].downcase
        when 'edit', 'update'
          :edit
        when 'new', 'create'
          :new
        else
          raise "Unknown command"
        end
      end
    end
  end
end
