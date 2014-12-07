module ROM
  module Rails
    RelationParamsMissingError = Class.new(StandardError)

    module ControllerExtension

      def self.included(klass)
        klass.extend(ClassExtensions)
      end

      def rom
        ::Rails.application.config.rom.env
      end

      module ClassExtensions

        def relation(path, options)
          root, method = path.split('.').map(&:to_sym)

          name = options.fetch(:as) { root }
          requires = Array(options.fetch(:requires) { [] })

          before_filter(options.except(:as, :requires)) do
            args = params.values_at(*requires)

            if requires.any? && args.none?
              raise RelationParamsMissingError
              false
            else
              relation =
                if args.any?
                  rom.read(root).send(method, *args)
                else
                  rom.read(root).send(method)
                end

              instance_variable_set("@#{name}", relation.to_a)
            end
          end

          unless respond_to?(name)
            attr_reader name
            helper_method name
          end
        end
      end

    end

  end
end
