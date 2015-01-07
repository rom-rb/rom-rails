require 'rails'

require 'rom/rails/inflections'
require 'rom/rails/configuration'
require 'rom/rails/controller_extension'

if defined?(Spring)
  Spring.after_fork { ROM::Rails::Railtie.disconnect }
end

module ROM
  module Rails
    class Railtie < ::Rails::Railtie
      def self.disconnect
        return unless ROM.env

        ROM.env.repositories.each_value do |repository|
          repository.adapter.disconnect
        end
      end

      def self.load_all
        %w(relations mappers commands).each do |type|
          load_files(type, ::Rails.root)
        end
      end

      def self.load_files(type, root)
        Dir[root.join("app/#{type}/**/*.rb").to_s].each do |path|
          load(path)
        end
      end

      initializer "rom.configure" do |app|
        config.rom = Configuration.build(app)
      end

      initializer "rom.load_schema" do |_app|
        require schema_file if schema_file.exist?
      end

      initializer "rom:prepare" do |app|
        config.to_prepare do |_config|
          Railtie.disconnect
          app.config.rom.setup!
          app.config.rom.load!
          app.config.rom.finalize!
          ActionController::Base.send(:include, ControllerExtension)
        end
      end

      private

      def schema_file
        root.join('db/rom/schema.rb')
      end

      def root
        ::Rails.root
      end
    end
  end
end
