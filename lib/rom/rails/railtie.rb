module ROM
  module Rails

    class Configuration
      attr_reader :config, :env

      def self.build(app)
        new(app.config.database_configuration[::Rails.env])
      end

      def initialize(config)
        @config = config
        @env = Environment.setup(@config)
      end
    end

    class Railtie < ::Rails::Railtie

      initializer "rom.configure" do |app|
        config.rom = ROM::Rails::Configuration.build(app)
      end

      initializer "rom.load_schema" do |app|
        require ::Rails.root.join('db/schema.rb')
      end

    end

  end
end
