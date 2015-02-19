require 'addressable/uri'

module ROM
  module Rails
    # A helper class to tranform a standard Rails database
    # configuration hash to a `rom-sql` configuration.
    #
    # This class builds a configuration array from a flat database
    # config hash.
    #
    # This is used to support typical database.yml-complaint
    # configs. It also uses adapter interface for things that are
    # adapter-specific like handling schema naming.
    #
    # @private
    module ConfigurationBuilder
      class ConfigurationHashTransformer
        BASE_OPTIONS = [
          :root,
          :adapter,
          :database,
          :password,
          :username,
          :hostname,
          :root
        ].freeze

        attr_reader :config

        def self.transform(config)
          new(config).transform
        end

        def self.root
          ::Rails.root
        end

        def initialize(config)
          @config = config.symbolize_keys
        end

        #
        # @return [Array]
        #
        # @api private
        def transform
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

          [:sql, uri, other_options]
        end

        def sqlite3_uri(uri_options)
          path = Pathname.new(self.class.root).join(uri_options.fetch(:database))

          build_uri(
                    scheme: 'sqlite',
                    host: '',
                    path: path.to_s
                   )
        end

        def postgresql_uri(uri_options)
          generic_uri(uri_options.merge(
                                   host: uri_options.fetch(:host) { '' },
                                   scheme: 'postgres'
                                  ))
        end

        def mysql_uri(uri_options)
          if uri_options.key?(:username) && !uri_options.key?(:password)
            uri_options.update(password: '')
          end

          generic_uri(uri_options)
        end

        def generic_uri(uri_options)
          build_uri(
                    scheme: uri_options.fetch(:scheme),
                    user: uri_options[:username],
                    password: uri_options[:password],
                    host: uri_options[:host],
                    port: uri_options[:port],
                    path: uri_options[:database]
                   )
        end

        def build_uri(attrs)
          Addressable::URI.new(attrs).to_s
        end
      end
    end
  end
end
