module ROM
  module Rails
    module ActiveRecord
      # A helper class to derive a repository configuration from ActiveRecord.
      #
      # @private
      class Configuration
        SCHEME_MAP = {'sqlite3' => 'sqlite', 'postgresql' => 'postgres'}.freeze

        BASE_OPTIONS = [
          :adapter,
          :database,
          :password,
          :username,
          :hostname,
          :root
        ].freeze

        # Returns repository configuration for the current environment.
        #
        # @note This relies on ActiveRecord being initialized already.
        # @param [Rails::Application]
        #
        # @api private
        def self.call(app)
          configuration = ::ActiveRecord::Base.configurations[::Rails.env]
                          .symbolize_keys
                          .update(root: app.config.root)

          build(configuration)
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
          root = config[:root]

          database = config[:database]
          password = config.fetch(:password) { '' }
          username = config[:username]
          hostname = config.fetch(:hostname) { 'localhost' }

          raw_scheme = scheme_for_adapter(config[:adapter])

          path =
            if raw_scheme == 'sqlite'
              [root, database].compact.join('/')
            else
              db_path = [hostname, database].join('/')

              if username && password
                [[username, password].join(':'), db_path].join('@')
              else
                db_path
              end
            end

          other_keys = config.keys - BASE_OPTIONS
          options = Hash[other_keys.zip(config.values_at(*other_keys))]

          # JRuby connection strings require special care.
          scheme = if RUBY_ENGINE == 'jruby'
                     scheme_for_jruby(scheme)
                   else
                     raw_scheme
                   end

          config_hash("#{scheme}://#{path}", options)
        end

        # Returns a Sequel-compatible scheme for an ActiveRecord adapter name.
        #
        # @api private
        def self.scheme_for_adapter(scheme)
          SCHEME_MAP.fetch(scheme) { |scheme| scheme }
        end

        # Rewrites schemes to use JDBC if appropriate.
        #
        # @api private
        def self.scheme_for_jruby(scheme)
          return scheme if scheme == 'postgres'
          "jdbc:#{scheme}"
        end

        # @api private
        def self.config_hash(uri, options = {})
          if options.any?
            { uri: uri, options: options }
          else
            uri
          end
        end
      end
    end
  end
end
