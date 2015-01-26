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
      initializer 'rom.configure_action_controller' do
        ActiveSupport.on_load(:action_controller) do
          ActionController::Base.send(:include, ControllerExtension)
        end
      end

      # Make `ROM::Rails::Configuration` instance available to the user via
      # `Rails.application.config` before other initializers run.
      config.before_initialize do |_app|
        config.rom = Configuration.new
      end

      # Reload ROM-related application code on each request.
      config.to_prepare do |_config|
        Railtie.reload if ROM.env
      end

      # This is where the initial setup of ROM occurs.
      # TODO: Freeze the configuration.
      config.after_initialize do |app|
        # At this point ActiveRecord::Base.configurations are already populated,
        # but ROM should NOT be yet. Will only be called once.
        fail if ROM.env

        if defined?(ActiveRecord) && !config.rom.repositories.key?(:default)
          uri, opts = ActiveRecord::Configuration.call(app)
                                                 .values_at(:uri, :options)

          config.rom.repositories[:default] = [:sql, uri, opts]
        end

        Railtie.setup
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

      def reload
        Railtie.disconnect
        Railtie.setup
      end

      def disconnect
        ROM.env.repositories.each_value do |repository|
          repository.disconnect
        end
      end

      def setup
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

      def load_all
        %w(relations mappers commands).each do |type|
          load_files(type)
        end
      end

      def load_files(type)
        Dir[root.join("app/#{type}/**/*.rb").to_s].each do |path|
          load(path)
        end
      end

      def root
        ::Rails.root
      end
    end
  end
end
