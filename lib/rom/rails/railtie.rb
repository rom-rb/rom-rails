module ROM
  module Rails

    class Configuration
      attr_reader :config, :env

      def self.build(app)
        config = rewrite_config(app)

        new(config)
      end

      def self.rewrite_config(app)
        root = app.config.root
        config = app.config.database_configuration[::Rails.env].symbolize_keys

        adapter = config[:adapter]
        database = config[:database]

        adapter = "sqlite" if adapter == "sqlite3"

        { default: "#{adapter}://#{root}/#{database}" }
      end

      def initialize(config)
        @config = config
        @env = ROM.setup(@config.symbolize_keys)
      end
    end

    class Railtie < ::Rails::Railtie

      initializer "rom.configure" do |app|
        config.rom = ROM::Rails::Configuration.build(app)
      end

      initializer "rom.load_schema" do |app|
        require schema_file if schema_file.exist?
      end

      initializer "rom.load_relations" do |app|
        relation_files.each { |file| require file }
      end

      initializer "rom.load_mappers" do |app|
        mapper_files.each { |file| require file }
      end

      private

      def schema_file
        root.join('db/rom/schema.rb')
      end

      def relation_files
        Dir[root.join('app/relations/**/*.rb').to_s]
      end

      def mapper_files
        Dir[root.join('app/mappers/**/*.rb').to_s]
      end

      def root
        ::Rails.root
      end

    end

  end
end
