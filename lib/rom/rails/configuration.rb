require 'dry/core/deprecations'

module ROM
  module Rails
    class Configuration
      extend Dry::Core::Deprecations[:configuration]
      include ActiveSupport::Configurable

      config_accessor :gateways do
        {}
      end

      config_accessor :auto_registration_paths do
        ['app']
      end
    end
  end
end
