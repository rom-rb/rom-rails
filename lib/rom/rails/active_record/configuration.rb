require_relative 'uri_builder'

module ROM
  module Rails
    module ActiveRecord
      # A helper class to derive `rom-sql` configuration from ActiveRecord.
      #
      # @private
      class Configuration
        BASE_OPTIONS = [
          :root,
          :adapter,
          :database,
          :password,
          :username,
          :hostname,
          :host
        ].freeze

        attr_reader :configurations
        attr_reader :env
        attr_reader :root
        attr_reader :uri_builder

        def initialize(env: ::Rails.env, root: ::Rails.root, configurations: ::ActiveRecord::Base.configurations)
          @configurations = configurations
          @env  = env
          @root = root

          @uri_builder = ROM::Rails::ActiveRecord::UriBuilder.new
        end

        # Returns gateway configuration for the current environment.
        #
        # @note This relies on ActiveRecord being initialized already.
        # @param [Rails::Application]
        #
        # @api private
        def call
          specs = {}

          if configurations.respond_to?(:default_hash)
            specs[:default] = build(configurations.default_hash.symbolize_keys)
          else
            specs[:default] = build(configurations.configs_for(env_name: env).first.configuration_hash.symbolize_keys)
          end

          configurations.configs_for(env_name: env).each do |config|
            name = config.respond_to?(:spec_name) ? config.spec_name : config.name
            hash = config.respond_to?(:configuration_hash) ? config.configuration_hash : config.config

            specs[name.to_sym] = build(hash.symbolize_keys)
          end

          specs
        end

        # Builds a configuration hash from a flat database config hash.
        #
        # This is used to support typical database.yml-complaint configs. It
        # also uses adapter interface for things that are adapter-specific like
        # handling schema naming.
        #
        # @param [Hash,String]
        # @return [Hash]
        #
        # @api private
        def build(config)
          adapter = config.fetch(:adapter)
          uri_options = config.except(:adapter).merge(
            root: root,
            scheme: adapter
          )
          other_options = config.except(*BASE_OPTIONS)

          uri = uri_builder.build(adapter, uri_options)
          { uri: uri, options: other_options }
        end

        private

        def rails7?
          ::ActiveRecord::VERSION::MAJOR == 7
        end

        def rails6?
          ::ActiveRecord::VERSION::MAJOR == 6
        end
      end
    end
  end
end
