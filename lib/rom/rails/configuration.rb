require 'dry/core/deprecations'

module ROM
  module Rails
    class Configuration
      extend Dry::Core::Deprecations[:configuration]

      attr_accessor :gateways
      attr_accessor :auto_registration_paths
      attr_accessor :reload_on_each_request

      def initialize
        @gateways = {}
        @auto_registration_paths = ['app']
        @reload_on_each_request = true
      end
    end
  end
end
