require 'generators/rom'

module ROM
  module Generators
    class FormGenerator < Base
      class_option :command,
        banner: "--command=command",
        desc: "specify command to use"

      def create_base_form
        template "base_form.rb.erb",
          File.join("app", "forms", "#{file_name.singularize}_form.rb")
      end

      def create_new
        create(:new) if create_new_form?
      end

      def create_edit
        create(:edit) if create_edit_form?
      end

      private

      def create(type)
        template "#{type}_form.rb.erb",
          File.join("app", "forms", "#{type}_#{file_name.singularize}_form.rb")
      end

      def create_new_form?
        options[:command].blank? || %w(new create).include?(options[:command].to_s.downcase)
      end

      def create_edit_form?
        options[:command].blank? || %w(edit update).include?(options[:command].to_s.downcase)
      end

      def model_name
        class_name.singularize.camelcase
      end

      def relation
        class_name.pluralize.underscore
      end
    end
  end
end
