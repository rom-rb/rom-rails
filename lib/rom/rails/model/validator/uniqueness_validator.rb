require 'active_model/validator'

module ROM
  module Model
    module Validator
      # Uniqueness validation
      #
      # @api public
      class UniquenessValidator < ActiveModel::EachValidator
        # Relation validator class
        #
        # @api private
        attr_reader :klass

        # error message
        #
        # @return [String, Symbol]
        #
        # @api private
        attr_reader :message

        # @api private
        def initialize(options)
          super
          @klass = options.fetch(:class)
          @message = options.fetch(:message) { :taken }
        end

        # Hook called by ActiveModel internally
        #
        # @api private
        def validate_each(validator, name, value)
          validator.errors.add(name, message) unless unique?(name, value)
        end

        private

        # Get relation object from the rom env
        #
        # @api private
        def relation
          rom.relations[relation_name]
        end

        # Relation name defined on the validator class
        #
        # @api private
        def relation_name
          klass.relation
        end

        # Shortcut to access global rom env
        #
        # @return [ROM::Env]
        #
        # @api private
        def rom
          ROM.env
        end

        # Ask relation if a given attribute value is unique
        #
        # This uses `Relation#unique?` interface that not all adapters can
        # implement.
        #
        # @return [TrueClass,FalseClass]
        #
        # @api private
        def unique?(name, value)
          relation.unique?(name => value)
        end
      end
    end
  end
end
