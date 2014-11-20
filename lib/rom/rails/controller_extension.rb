module ROM
  module Rails

    module ControllerExtension

      def rom
        ::Rails.application.config.rom.env
      end

    end

  end
end
