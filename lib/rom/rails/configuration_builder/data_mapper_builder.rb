require 'rom/rails/configuration_builder/configuration_hash_transformer'

module ROM
  module Rails
    # A helper class to derive a repository configuration from an
    # existing DataMapper configuration (via dm-rails).
    #
    # @private
    module ConfigurationBuilder
      module DataMapperBuilder
        def self.config
          ::Rails::DataMapper.configuration.repositories
            .fetch(::Rails.env).fetch('default')
        end

        def self.buildable?
          defined?(::Rails::DataMapper)
        end

        def self.build
          ConfigurationHashTransformer.build(config)
        end
      end
    end
  end
end
