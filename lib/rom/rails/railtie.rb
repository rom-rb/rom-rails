require 'rails'

require 'rom/rails/inflections'
require 'rom/rails/configuration'
require 'rom/rails/controller_extension'
require 'rom/rails/active_record/configuration'

Spring.after_fork { ROM::Rails::Railtie.disconnect } if defined?(Spring)

module ROM
  module Rails
    class Railtie < ::Rails::Railtie
      COMPONENT_DIRS = %w(relations mappers commands).freeze

      MissingGatewayConfigError = Class.new(StandardError)

      # Make `ROM::Rails::Configuration` instance available to the user via
      # `Rails.application.config` before other initializers run.
      config.before_initialize do |_app|
        config.rom = Configuration.new
      end

      initializer 'rom.configure_action_controller' do
        ActiveSupport.on_load(:action_controller) do
          ActionController::Base.send(:include, ControllerExtension)
        end
      end

      initializer 'rom.adjust_eager_load_paths' do |app|
        paths =
          auto_registration_paths.inject([]) do |result, root_path|
            result.concat(COMPONENT_DIRS.map { |dir| root_path.join('app', dir).to_s })
          end

        app.config.eager_load_paths -= paths
      end

      rake_tasks do
        load "rom/rails/tasks/db.rake" unless active_record?
      end

      # Reload ROM-related application code on each request.
      config.to_prepare do |_config|
        ROM.env = Railtie.create_container
      end
      
      console do |app|
        unless ActiveSupport::Logger.logger_outputs_to?(Rails.logger, STDERR, STDOUT)
          console = ActiveSupport::Logger.new(STDERR)
          Rails.logger.extend ActiveSupport::Logger.broadcast console
        end
      end
      
      # Behaves like `Railtie#configure` if the given block does not take any
      # arguments. Otherwise yields the ROM configuration to the block.
      #
      # @example
      #   ROM::Rails::Railtie.configure do |config|
      #     config.gateways[:default] = [:yaml, 'yaml:///data']
      #     config.auto_registration_paths += [MyEngine.root]
      #   end
      #
      # @api public
      def configure(&block)
        config.rom = Configuration.new unless config.respond_to?(:rom)

        if block.arity == 1
          block.call(config.rom)
        else
          super
        end
      end

      def create_configuration
        ROM::Configuration.new(gateways)
      end

      # @api private
      def create_container
        configuration = create_configuration

        auto_registration_paths.each do |root_path|
          configuration.auto_registration(root_path.join('app'), namespace: false)
        end

        ROM.container(configuration)
      end

      # @api private
      def gateways
        config.rom.gateways[:default] ||= infer_default_gateway if active_record?

        raise(
          MissingGatewayConfigError,
          "seems like you didn't configure any gateways"
        ) unless config.rom.gateways.any?

        config.rom.gateways
      end

      # If there's no default gateway configured, try to infer it from
      # other sources, e.g. ActiveRecord.
      #
      # @api private
      def infer_default_gateway
        spec = ROM::Rails::ActiveRecord::Configuration.call
        [:sql, spec[:uri], spec[:options]]
      end

      def load_initializer
        load "#{root}/config/initializers/rom.rb"
      rescue LoadError
        # do nothing
      end

      # @api private
      def disconnect
        container.disconnect unless container.nil?
      end

      # @api private
      def root
        ::Rails.root
      end

      def container
        ROM.env
      end

      def auto_registration_paths
        config.rom.auto_registration_paths + [root]
      end

      # @api private
      def active_record?
        defined?(::ActiveRecord)
      end
    end
  end
end
