require 'addressable/uri'

module ROM
  module Rails
    module ActiveRecord
      class UriBuilder
        def build(adapter, uri_options)
          builder_method = :"#{adapter}_uri"

          uri = if respond_to?(builder_method)
                  send(builder_method, uri_options)
                else
                  generic_uri(uri_options)
                end

          # JRuby connection strings require special care.
          if RUBY_ENGINE == 'jruby' && adapter != 'postgresql'
            uri = "jdbc:#{uri}"
          end

          uri
        end

        def sqlite3_uri(config)
          path = Pathname.new(config.fetch(:root)).join(config.fetch(:database))

          build_uri(
            scheme: 'sqlite',
            host: '',
            path: path.to_s
          )
        end

        def postgresql_uri(config)
          generic_uri(config.merge(
                        host: config.fetch(:host) { '' },
                        scheme: 'postgres'
                      ))
        end

        def mysql_uri(config)
          if config.key?(:username) && !config.key?(:password)
            config.update(password: '')
          end

          generic_uri(config)
        end

        def generic_uri(config)
          build_uri(
            scheme: config.fetch(:scheme),
            user: escape_option(config[:username]),
            password: escape_option(config[:password]),
            host: config[:host],
            port: config[:port],
            path: config[:database]
          )
        end

        def build_uri(attrs)
          Addressable::URI.new(attrs).to_s
        end

        def escape_option(option)
          option.nil? ? option : CGI.escape(option)
        end
      end
    end
  end
end
