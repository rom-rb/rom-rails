require 'addressable/uri'

module ROM
  module Rails
    # A helper class to derive `rom-sql` configuration from common
    # configuration methods.
    #
    # @private
    class RepositoryConfiguration
      BASE_OPTIONS = [
        :root,
        :adapter,
        :database,
        :password,
        :username,
        :hostname,
        :root
      ].freeze

      # Returns whether repository configuration can be inferred.
      #
      # @return [Boolean]
      #
      # @api private
      def self.inferrable?
        !!inferrable_configuration
      end

      # Returns the configuration hash for an available ORM.
      #
      # @note This relies on the configuration having been initialized already.
      #
      # @return [Hash]
      #
      # @api private
      def self.inferrable_configuration
        @configuration ||=
          if defined?(::ActiveRecord)
            ::ActiveRecord::Base.configurations.fetch(::Rails.env)
          elsif defined?(::Rails::DataMapper)
            ::Rails::DataMapper.configuration.repositories.fetch(::Rails.env).fetch('default')
          end
      end

      # Returns repository configuration for the current environment.
      #
      # @note This relies on the configuration having been initialized already.
      #
      # @api private
      def self.infer
        build(inferrable_configuration.symbolize_keys.update(root: ::Rails.root))
      end

      # Builds a configuration hash from a flat database config hash.
      #
      # This is used to support typical database.yml-complaint configs. It
      # also uses adapter interface for things that are adapter-specific like
      # handling schema naming.
      #
      # @param [Hash,String]
      # @return [Hash]
      #
      # @api private
      def self.build(config)
        adapter = config.fetch(:adapter)
        uri_options = config.except(:adapter).merge(scheme: adapter)
        other_options = config.except(*BASE_OPTIONS)

        builder_method = :"#{adapter}_uri"
        uri = if respond_to?(builder_method)
                send(builder_method, uri_options)
              else
                generic_uri(uri_options)
              end

        # JRuby connection strings require special care.
        uri = if RUBY_ENGINE == 'jruby' && adapter != 'postgresql'
                "jdbc:#{uri}"
              else
                uri
              end

        { uri: uri, options: other_options }
      end

      def self.sqlite3_uri(config)
        path = Pathname.new(config.fetch(:root)).join(config.fetch(:database))

        build_uri(
          scheme: 'sqlite',
          host: '',
          path: path.to_s
        )
      end

      def self.postgresql_uri(config)
        generic_uri(config.merge(
          host: config.fetch(:host) { '' },
          scheme: 'postgres'
        ))
      end

      def self.mysql_uri(config)
        if config.key?(:username) && !config.key?(:password)
          config.update(password: '')
        end

        generic_uri(config)
      end

      def self.generic_uri(config)
        build_uri(
          scheme: config.fetch(:scheme),
          user: config[:username],
          password: config[:password],
          host: config[:host],
          port: config[:port],
          path: config[:database]
        )
      end

      def self.build_uri(attrs)
        Addressable::URI.new(attrs).to_s
      end
    end
  end
end
