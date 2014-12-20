require 'generators/rom'

module ROM
  module Generators
    class RelationGenerator < Base

      def create_relation_file
        template(
          'relation.rb.erb',
          File.join('app', 'relations', "#{file_name}.rb")
        )
      end

    end
  end
end
