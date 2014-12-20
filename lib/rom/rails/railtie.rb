require 'rom/rails/inflections'

if defined?(Spring)
  Spring.after_fork do
    ROM.env.repositories.each_value do |repository|
      repository.adapter.disconnect
    end
  end
end

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

    class Railtie < ::Rails::Railtie

      def self.load_all
        %w(relations mappers commands).each { |type| load_files(type, ::Rails.root) }
      end

      def self.load_files(type, root)
        Dir[root.join("app/#{type}/**/*.rb").to_s].each do |path|
          load(path)
        end
      end

      initializer "rom.configure" do |app|
        config.rom = ROM::Rails::Configuration.build(app)
      end

      initializer "rom.load_schema" do |app|
        require schema_file if schema_file.exist?
      end

      config.after_initialize do |app|
        ApplicationController.send(:include, ControllerExtension)
      end

      initializer "rom:prepare" do |app|
        config.to_prepare do |config|
          app.config.rom.setup!
          app.config.rom.load!
          app.config.rom.finalize!
        end
      end

      private

      def schema_file
        root.join('db/rom/schema.rb')
      end

      def root
        ::Rails.root
      end

    end

  end
end
