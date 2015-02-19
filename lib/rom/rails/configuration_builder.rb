require 'rom/rails/configuration_builder/config_file_builder'
require 'rom/rails/configuration_builder/active_record_builder'
require 'rom/rails/configuration_builder/data_mapper_builder'
require 'rom/rails/configuration_builder/environment_builder'

module ROM
  module Rails
    # A helper class that selects a preferred method from available
    # configuration methods and derives a repository configuration.
    #
    # @private
    module ConfigurationBuilder
      BUILDERS = [
        ConfigFileBuilder,
        ActiveRecordBuilder,
        DataMapperBuilder,
        EnvironmentBuilder
      ]

      def self.build
        # By the time we've got here, we've already passed two points
        # where ROM may have been configured:
        #
        #  1. Configuration within an initializer
        #  2. Configuration by reading `config/rom.yml`
        #
        # This means we're now looking to infer the configuration from
        # some other source:
        #
        #  1. `config/database.yml`
        #  2. ActiveRecord configuration
        #  3. DataMapper configuration
        #  4. The DATABASE_URL environment variable
        builder = BUILDERS.find(&:buildable?)
        if builder
          builder.build
        else
          raise "Unable to build an inferred repository configuration"
        end
      end
    end
  end
end
