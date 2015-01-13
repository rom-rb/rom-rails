require 'rom/rails/active_record/configuration'

module ROM
  module Rails
    class Configuration
      attr_reader :repositories


      # Uses database configuration from Rails to configure repositories.
      #
      # Note that the `DATABASE_URL` environment variable supported by
      # ActiveRecord will *NOT* be respected.
      #
      # @param [Rails::Application] app
      # @return [Hash]
      #
      # @api private
      def self.derive_repos_from_application(app)
        config = app.config.database_configuration[::Rails.env].
                            symbolize_keys.update(root: app.config.root)

        ActiveRecord::Configuration.build(config)
      end

      def initialize(config = Hash.new)
        @repositories = config.fetch(:repositories) { Hash.new }
      end
    end
  end
end
