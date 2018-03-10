require 'generators/rom'

module ROM
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      def self.namespace
        "rom:#{generator_name}"
      end

      class_option :adapter,
        banner: '--adapter=adapter',
        desc: "specify an adapter to use", required: true,
        default: "sql"

      def create_initializer
        template 'initializer.rb.erb',
          File.join('config', 'initializers', 'rom.rb')
      end

      def self.source_root
        File.expand_path("../install/templates", __FILE__)
      end


    private

      def adapter
        options[:adapter].to_sym
      end

    end
  end
end
