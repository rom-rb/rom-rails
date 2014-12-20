module ROM
  module Rails
    class Configuration
      attr_reader :config, :setup, :env

      def self.build(app)
        root = app.config.root
        db_config = app.config.database_configuration[::Rails.env].symbolize_keys

        config = rewrite_config(root, db_config)

        new(config)
      end

      def self.rewrite_config(root, config)
        adapter = config[:adapter]
        database = config[:database]
        password = config[:password]
        username = config[:username]
        hostname = config.fetch(:hostname) { 'localhost' }

        adapter = "sqlite" if adapter == "sqlite3"

        path =
          if adapter == "sqlite"
            "#{root}/#{database}"
          else
            db_path = [hostname, database].join('/')

            if username && password
              [[username, password].join(':'), db_path].join('@')
            else
              db_path
            end
          end

        { default: "#{adapter}://#{path}" }
      end

      def initialize(config)
        @config = config.symbolize_keys
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
        #
        # FIXME: ROM should raise a custom error
        @env = ROM.finalize.env rescue KeyError
      end
    end
  end
end
