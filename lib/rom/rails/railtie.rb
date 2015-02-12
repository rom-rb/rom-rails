require 'rails'

require 'rom/rails/inflections'
require 'rom/rails/configuration'
require 'rom/rails/controller_extension'
require 'rom/rails/active_record/configuration'

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

      initializer 'rom.adjust_eager_load_paths' do |app|
        paths = %w(commands mappers relations).map do |directory|
          ::Rails.root.join('app', directory).to_s
        end

        app.config.eager_load_paths -=  paths
      end

      # Make `ROM::Rails::Configuration` instance available to the user via
      # `Rails.application.config` before other initializers run.
      config.before_initialize do |_app|
        config.rom = Configuration.new
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

      def disconnect
        # TODO: Add `ROM.env.disconnect` to core.
        ROM.env.repositories.each_value do |repository|
          repository.disconnect
        end
      end

      def setup
        if ROM.env
          ROM.setup(ROM.env.repositories)
        else
          repositories = config.rom.repositories

          # If there's no default repository configured, try to infer it from
          # other sources, e.g. ActiveRecord.
          repositories[:default] ||= infer_default_repository

          ROM.setup(repositories.symbolize_keys)
        end
        clear_classes
        load_all
        ROM.finalize
      end

      def infer_default_repository
        return unless defined?(::ActiveRecord)
        spec = ActiveRecord::Configuration.call
        [:sql, spec[:uri], spec[:options]]
      end

      def load_all
        %w(relations mappers commands).each do |type|
          load_files(type)
        end
      end

      def load_files(type)
        Dir[root.join("app/#{type}/**/*.rb").to_s].each do |path|
          require_dependency(path)
        end
      end

      def clear_classes
        [Relation, Mapper, Command].each { |klass| clear_descendants(klass) }
      end

      def clear_descendants(klass)
        klass.descendants.each { |descendant| clear_descendants(descendant) }
        klass.instance_variable_set('@descendants', [])
      end

      def root
        ::Rails.root
      end
    end
  end
end
