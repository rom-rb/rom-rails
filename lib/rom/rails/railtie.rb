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

      attr_accessor :rake_mode

      MissingRepositoryConfigError = Class.new(StandardError)

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
        paths = COMPONENT_DIRS.map do |directory|
          root.join('app', directory).to_s
        end

        app.config.eager_load_paths -= paths
      end

      rake_tasks do
        load "rom/rails/tasks/db.rake" unless self.class.active_record?
        self.rake_mode = true
      end

      # Reload ROM-related application code on each request.
      config.to_prepare do |_config|
        Railtie.finalize
      end

      # Behaves like `Railtie#configure` if the given block does not take any
      # arguments. Otherwise yields the ROM configuration to the block.
      #
      # @example
      #   ROM::Rails::Railtie.configure do |config|
      #     config.repositories[:default] = [:yaml, 'yaml:///data']
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

      # @api private
      def setup(repositories)
        raise(
          MissingRepositoryConfigError,
          "seems like you didn't configure any repositories"
        ) unless repositories.any?

        ROM.setup(repositories)
      end

      # @api private
      def finalize
        repositories =
          if env
            env.repositories
          else
            prepare_repositories
          end

        setup(repositories)

        if rake_mode
          puts '<= skipping loading rom components'
        else
          load_components
        end

        ROM.finalize
      end

      # TODO: Add `ROM.env.disconnect` to core.
      #
      # @api private
      def disconnect
        env.repositories.each_value(&:disconnect)
      end

      # @api private
      def prepare_repositories
        config.rom.repositories[:default] ||= infer_default_repository if active_record?
        config.rom.repositories
      end

      # If there's no default repository configured, try to infer it from
      # other sources, e.g. ActiveRecord.
      #
      # @api private
      def infer_default_repository
        spec = ROM::Rails::ActiveRecord::Configuration.call
        [:sql, spec[:uri], spec[:options]]
      end

      # @api private
      def load_components
        COMPONENT_DIRS.each { |type| load_files(type) }
      end

      # @api private
      def load_files(type)
        Dir[root.join("app/#{type}/**/*.rb")].each do |path|
          require_dependency(path)
        end
      end

      # @api private
      def root
        ::Rails.root
      end

      # @api private
      def env
        ROM.env
      end

      # @api private
      def active_record?
        defined?(::ActiveRecord)
      end
    end
  end
end
