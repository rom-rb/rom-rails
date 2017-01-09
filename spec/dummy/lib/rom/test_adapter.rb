module ROM
  module TestAdapter
    class Relation < ROM::Relation
      adapter :test_adapter
      schema_class Schema
    end

    class Gateway < ROM::Gateway
      include Equalizer.new(:args)

      attr_reader :args, :datasets

      def initialize(args)
        @args = args
        @datasets = {}
      end

      def dataset(name)
        @datasets[name] = []
      end

      def dataset?(name)
        datasets.key?(name)
      end
    end
  end
end

ROM.register_adapter(:test_adapter, ROM::TestAdapter)
