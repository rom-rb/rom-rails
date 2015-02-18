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
    end
  end
end
