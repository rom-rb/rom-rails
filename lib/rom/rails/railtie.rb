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
            if username && password
              [[username, password].join(':'), [hostname, database].join('/')].join('@')
            else
              [hostname, database].join('/')
            end
          end

        { default: "#{adapter}://#{path}" }
      end

      def initialize(config)
        @config = config
        @setup = ROM.setup(@config.symbolize_keys)
      end

      def finalize
        @env = setup.finalize
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

      config.after_initialize do |app|
        app.config.rom.finalize
        ApplicationController.send(:include, ControllerExtension)
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
