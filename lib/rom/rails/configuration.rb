module ROM
  module Rails
    class Configuration
      attr_reader :config

      def self.build(app)
        config = app.config.database_configuration[::Rails.env].
          symbolize_keys.update(root: app.config.root)

        new(ROM::Config.build(config))
      end

      def initialize(config)
        @config = config
      end
    end
  end
end
