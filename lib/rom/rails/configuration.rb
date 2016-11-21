require 'rom/support/deprecations'

module ROM
  module Rails
    class Configuration
      extend ROM::Deprecations
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
