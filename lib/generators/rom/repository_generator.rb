require 'generators/rom'

if defined? ROM::Repository
  module ROM
    module Generators
      class RepositoryGenerator < Base
        def create_repository_file
          template(
            'repository.rb.erb',
            File.join('app', 'repositories', "#{repository_name}_repository.rb")
          )
        end

        private

        def relation
          class_name.pluralize.underscore
        end

        def model_name
          class_name.singularize.camelcase
        end

        def repository_name
          class_name.singularize.underscore
        end

        def mapper
          repository_name
        end
      end
    end
  end
end
