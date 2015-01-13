require 'rom/rails/active_record/configuration'

module ROM
  module Rails
    class Configuration
      attr_reader :repositories

      def initialize(config = Hash.new)
        @repositories = config.fetch(:repositories) { Hash.new }
      end
    end
  end
end
