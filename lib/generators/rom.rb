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
        File.expand_path("../#{base_name}/#{generator_name}/templates", __FILE__)
      end
    end
  end
end
