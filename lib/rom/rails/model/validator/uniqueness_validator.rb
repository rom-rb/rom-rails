module ROM
  module Model
    module Validator
      class UniquenessValidator < ActiveModel::EachValidator
        attr_reader :klass

        def initialize(options)
          super
          @klass = options.fetch(:class)
        end

        def validate_each(validator, name, value)
          validator.errors.add(name, :taken) unless unique?(name, value)
        end

        private

        def relation
          rom.relations[relation_name]
        end

        def relation_name
          klass.relation
        end

        def rom
          ROM.env
        end

        def unique?(name, value)
          relation.unique?(name => value)
        end
      end
    end
  end
end
