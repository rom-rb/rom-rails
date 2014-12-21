require 'rails'

require 'rom/rails/inflections'
require 'rom/rails/configuration'
require 'rom/rails/controller_extension'

if defined?(Spring)
  Spring.after_fork do
    ROM.env.repositories.each_value do |repository|
      repository.adapter.disconnect
    end
  end
end

module ROM
  module Rails

    class Railtie < ::Rails::Railtie

      def self.load_all
        %w(relations mappers commands).each { |type| load_files(type, ::Rails.root) }
      end

      def self.load_files(type, root)
        Dir[root.join("app/#{type}/**/*.rb").to_s].each do |path|
          load(path)
        end
      end

      initializer "rom.configure" do |app|
        config.rom = ROM::Rails::Configuration.build(app)
      end

      initializer "rom.load_schema" do |app|
        require schema_file if schema_file.exist?
      end

      config.after_initialize do |app|
        ApplicationController.send(:include, ControllerExtension)
      end

      initializer "rom:prepare" do |app|
        config.to_prepare do |config|
          app.config.rom.setup!
          app.config.rom.load!
          app.config.rom.finalize!
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
