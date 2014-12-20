require 'rails/generators'

module ROM
  module Rails
    class RelationGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      def create_relation_file
        template(
          'relation.rb.erb',
          File.join('app', 'relations', "#{file_name}.rb")
        )
      end
    end
  end
end
