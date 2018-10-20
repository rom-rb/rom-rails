require 'rails/generators/named_base'
require 'rom/rails/inflections'

module ROM
  module Generators
    class Base < ::Rails::Generators::NamedBase
      def self.base_name
        'rom'
      end

      def self.namespace
        "rom:#{generator_name}"
      end

      def self.source_root
        File.expand_path(
          "../#{base_name}/#{generator_name}/templates",
          __FILE__
        )
      end

      def self.default_gateway
        ROM.env.gateways[:default]
      end

      def self.default_adapter
        (default_gateway && default_gateway.adapter)
      end
    end
  end
end
