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
          @scope_keys = options[:scope]
        end

        # Hook called by ActiveModel internally
        #
        # @api private
        def validate_each(validator, name, value)
          scope = Array(@scope_keys).each_with_object({}) do |key, scope|
            scope[key] = validator.to_model[key]
          end
          validator.errors.add(name, message) unless unique?(name, value, scope)
        end

        private

        # Get relation object from the rom env
        #
        # @api private
        def relation
          if relation_name
            rom.relations[relation_name]
          else
            raise "relation must be specified to use uniqueness validation"
          end
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
        def unique?(name, value, scope)
          relation.unique?({name => value}.merge(scope))
        end
      end
    end
  end
end
