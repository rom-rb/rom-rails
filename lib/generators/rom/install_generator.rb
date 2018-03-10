require 'generators/rom'

module ROM
  module Generators
    class InstallGenerator < Base

      class_option :adapter,
        banner: '--adapter=adapter',
        desc: "specify an adapter to use", required: true,
        default: "sql"

      def create_initializer
        template 'initializer.rb.erb',
          File.join('config', 'initializers', 'rom.rb')
      end

    private

      def adapter
        options[:adapter].to_sym
      end

    end
  end
end
