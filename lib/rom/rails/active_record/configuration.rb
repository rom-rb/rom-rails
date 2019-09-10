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

        # Returns gateway configuration for the current environment.
        #
        # @note This relies on ActiveRecord being initialized already.
        # @param [Rails::Application]
        #
        # @api private
        def self.call
          configuration = ::ActiveRecord::Base.configurations.fetch(::Rails.env)
          build(configuration.symbolize_keys.update(root: ::Rails.root))
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
        def self.build(config)
          adapter = config.fetch(:adapter)
          uri_options = config.except(:adapter).merge(scheme: adapter)
          other_options = config.except(*BASE_OPTIONS)

          builder = ROM::Rails::ActiveRecord::UriBuilder.new

          uri = builder.build(adapter, uri_options)
          { uri: uri, options: other_options }
        end

      end
    end
  end
end
