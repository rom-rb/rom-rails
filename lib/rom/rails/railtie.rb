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

      # Derive ROM configuration from the application and make it available to
      # the user via `Rails.application.config` before other initializers run.
      config.before_initialize do |app|
        config.rom = Configuration.build(app)
      end

      initializer "rom.load_schema" do |_app|
        require schema_file if schema_file.exist?
      end

      initializer "rom:prepare" do |app|
        config.to_prepare do |_config|
          Railtie.disconnect
          Railtie.setup!
          ActionController::Base.send(:include, ControllerExtension)
        end
      end

      # Behaves like `Railtie#configure` if the given block does not take any
      # arguments. Otherwise yields the ROM configuration to the block.
      #
      # @example
      #   ROM::Rails::Railtie.configure do |config|
      #     config.repositories[:yaml] = {uri: 'yaml:///data'}
      #   end
      #
      # @api public
      def configure(&block)
        if block.arity == 1
          block.call(config.rom)
        else
          super
        end
      end

      private

      def self.setup!
        ROM.setup(config.rom.repositories.symbolize_keys)

        load_all

        begin
          # rescuing fixes the chicken-egg problem where we have a relation
          # defined but the table doesn't exist yet
          ROM.finalize.env
        rescue Registry::ElementNotFoundError => e
          warn "Skipping ROM setup => #{e.message}"
        end
      end

      def schema_file
        root.join('db/rom/schema.rb')
      end

      def root
        ::Rails.root
      end
    end
  end
end
