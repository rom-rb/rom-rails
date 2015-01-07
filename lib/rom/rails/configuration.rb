module ROM
  module Rails
    class Configuration
      attr_reader :repositories

      # Tries to guess the right ROM configuration for a Rails app.
      #
      # @param [Rails::Application] app
      # @return [Configuration]
      #
      # @api private
      def self.build(app)
        new(repositories: derive_repos_from_application(app))
      end

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

        ROM::Config.build(config)
      end

      def initialize(config)
        @repositories = config.fetch(:repositories)
      end
    end
  end
end
