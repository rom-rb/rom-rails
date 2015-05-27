require 'virtus'

module ROM
  module Rails
    class Configuration
      include Virtus.model(strict: true)

      attribute :gateways, Hash, default: {}
    end
  end
end
