require 'generators/rom'

module ROM
  module Generators
    class RelationGenerator < Base
      class_option :adapter,
        banner: "--adapter=adapter",
        desc: "specify an adapter to use", required: true,
        default: ROM.adapters.keys.first

      class_option :gateway,
        banner: "--gateway=repo",
        desc: "specify a gateway to connect to",
        required: false

      class_option :register,
        banner: "--register=name",
        desc: "specify the registration identifier",
        required: false

      def create_relation_file
        template(
          'relation.rb.erb',
          File.join('app', 'relations', "#{file_name}_relation.rb")
        )
      end

      private

      def dataset
        class_name.underscore.pluralize
      end

      def adapter
        options[:adapter]
      end

      def register_as
        options[:register] || dataset
      end

      def gateway
        options[:gateway]
      end
    end
  end
end
