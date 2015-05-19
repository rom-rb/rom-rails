require 'rom/rails/configuration_builder/configuration_hash_transformer'

module ROM
  module Rails
    # A helper class to derive a repository configuration from an
    # existing ActiveRecord configuration.
    #
    # @private
    module ConfigurationBuilder
      module ActiveRecordBuilder
        def self.config
          ::ActiveRecord::Base.configurations
            .fetch(::Rails.env)
        end

        def self.buildable?
          defined?(::ActiveRecord)
        end

        def self.build
          ConfigurationHashTransformer.transform(config)
        end
      end
    end
  end
end
