require 'rom/rails/configuration_builder/configuration_hash_transformer'

module ROM
  module Rails
    # A helper class to derive a repository configuration from Rails
    # database configuration methods (which will usually be
    # database.yml).
    #
    # @private
    module ConfigurationBuilder
      module ConfigFileBuilder
        def self.config
          ::Rails.configuration.database_configuration
            .fetch(::Rails.env)
        rescue
          # This rescue block is required as the call to
          # Rails.configuration.database_configuration results in a
          # RuntimeError if there is no database.yml file.  If a
          # DATABASE_URL environment variable is present we also fall
          # through to here as the implementation returns an empty
          # Hash which then results in an exception as the #fetch call
          # fails.
          nil
        end

        def self.buildable?
          !config.blank?
        end

        def self.build
          ConfigurationHashTransformer.transform(config)
        end
      end
    end
  end
end
