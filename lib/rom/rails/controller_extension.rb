module ROM
  module Rails
    RelationParamsMissingError = Class.new(StandardError)

    module ControllerExtension
      def rom
        ROM.env
      end
    end
  end
end
