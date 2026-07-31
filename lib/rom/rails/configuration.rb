module ROM
  module Rails
    class Configuration
      attr_accessor :gateways, :auto_registration_paths, :reload_on_each_request

      def initialize
        @gateways = {}
        @auto_registration_paths = ['app']
        @reload_on_each_request = true
      end
    end
  end
end
