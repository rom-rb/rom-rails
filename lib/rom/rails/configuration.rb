module ROM
  module Rails
    class Configuration
      attr_reader :config, :setup, :env

      def self.build(app)
        config = app.config.database_configuration[::Rails.env].
          symbolize_keys.update(root: app.config.root)

        new(ROM::Config.build(config))
      end

      def initialize(config)
        @config = config
      end

      def setup!
        @setup = ROM.setup(@config.symbolize_keys)
      end

      def load!
        Railtie.load_all
      end

      def finalize!
        # rescuing fixes the chicken-egg problem where we have a relation
        # defined but the table doesn't exist yet
        @env = ROM.finalize.env
      rescue Registry::ElementNotFoundError => e
        warn "Skipping ROM setup => #{e.message}"
      end
    end
  end
end
