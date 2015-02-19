require 'virtus'

module ROM
  module Rails
    class Configuration
      include Virtus.model(strict: true)

      attribute :repositories, Hash, default: {}
    end
  end
end
