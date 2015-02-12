require 'generators/rom'

module ROM
  module Generators
    class RelationGenerator < Base
      class_option :adapter, banner: "--adapter=adapter",
        desc: "specify an adapter to use"

      def create_relation_file
        template(
          'relation.rb.erb',
          File.join('app', 'relations', "#{file_name}.rb")
        )
      end
    end
  end
end
