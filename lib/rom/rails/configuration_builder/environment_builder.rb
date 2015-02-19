module ROM
  module Rails
    # A helper to derive a repository configuration from environment
    # variables.
    #
    # @private
    module ConfigurationBuilder
      module EnvironmentBuilder
        def self.buildable?
          ENV['DATABASE_URL'].present?
        end

        def self.build
          [:sql, ENV['DATABASE_URL']]
        end
      end
    end
  end
end
