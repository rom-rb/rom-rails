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

      MissingRepositoryConfigError = Class.new(StandardError)

      # @api public
      def self.setup_repositories
        raise(
          MissingRepositoryConfigError,
          "seems like you didn't configure any repositories"
        ) unless config.rom.repositories.any?

        ROM.setup(config.rom.repositories)
        self
      end

      # @api public
      def self.finalize
        ROM.finalize
        self
      end

      # If there's no default repository configured, try to infer it from
      # other sources, e.g. ActiveRecord.
      #
      # @api private
      def self.infer_default_repository
        return unless active_record?
        spec = ROM::Rails::ActiveRecord::Configuration.call
        [:sql, spec[:uri], spec[:options]]
      end

      # @api private
      def self.active_record?
        defined?(::ActiveRecord)
      end

      # @api private
      def before_initialize
        config.rom = Configuration.new
      end

      initializer 'rom.configure_action_controller' do
        ActiveSupport.on_load(:action_controller) do
          ActionController::Base.send(:include, ControllerExtension)
        end
      end

      initializer 'rom.adjust_eager_load_paths' do |app|
        paths = COMPONENT_DIRS.map do |directory|
          ::Rails.root.join('app', directory).to_s
        end

        app.config.eager_load_paths -= paths
      end

      rake_tasks do
        load "rom/rails/tasks/db.rake" unless self.class.active_record?
      end

      # Make `ROM::Rails::Configuration` instance available to the user via
      # `Rails.application.config` before other initializers run.
      config.before_initialize do |_app|
        before_initialize
      end

      # Reload ROM-related application code on each request.
      config.to_prepare do |_config|
        Railtie.setup
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

      # TODO: Add `ROM.env.disconnect` to core.
      #
      # @api private
      def disconnect
        ROM.env.repositories.each_value(&:disconnect)
      end

      # @api private
      def setup
        if ROM.env
          ROM.setup(ROM.env.repositories)
        else
          repositories = config.rom.repositories

          if self.class.active_record?
            repositories[:default] ||= self.class.infer_default_repository
          end

          self.class.setup_repositories
        end
        load_all
        self.class.finalize
      end

      # @api private
      def load_all
        COMPONENT_DIRS.each do |type|
          load_files(type)
        end
      end

      # @api private
      def load_files(type)
        Dir[root.join("app/#{type}/**/*.rb").to_s].each do |path|
          require_dependency(path)
        end
      end

      # @api private
      def root
        ::Rails.root
      end
    end
  end
end
