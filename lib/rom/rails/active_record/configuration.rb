module ROM
  module Rails
    module ActiveRecord
      # A helper class to derive a repository configuration from ActiveRecord.
      #
      # @private
      class Configuration
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
        def self.build(config, options = {})
          return config unless config[:database]

          root = config[:root]

          raw_scheme = config[:adapter]

          database = config[:database]
          password = config.fetch(:password) { '' }
          username = config[:username]
          hostname = config.fetch(:hostname) { 'localhost' }

          adapter = Adapter[raw_scheme]
          scheme = adapter.normalize_scheme(raw_scheme)

          path =
            if adapter.database_file?(scheme)
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

          config_hash("#{scheme}://#{path}", options)
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
