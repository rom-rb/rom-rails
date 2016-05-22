require 'generators/rom'

module ROM
  module Generators
    class MapperGenerator < Base
      def create_mapper_file
        template(
          'mapper.rb.erb',
          File.join('app', 'mappers', "#{file_name.singularize}_mapper.rb")
        )
      end

      private

      def model_name
        class_name.singularize
      end

      def relation
        class_name.pluralize.underscore
      end

      def register_as
        model_name.singularize.underscore.downcase
      end
    end
  end
end
