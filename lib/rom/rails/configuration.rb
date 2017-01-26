require 'dry/core/deprecations'

module ROM
  module Rails
    class Configuration
      extend Dry::Core::Deprecations[:rom]
      include ActiveSupport::Configurable

      config_accessor :gateways do
        {}
      end

      config_accessor :auto_registration_paths do
        []
      end

      deprecate :repositories, :gateways
    end
  end
end
