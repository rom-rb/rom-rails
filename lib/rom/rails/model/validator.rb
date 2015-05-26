require 'rom/rails/model/validator/uniqueness_validator'
require 'rom/support/class_macros'

module ROM
  module Model
    # Mixin for ROM-compliant validator objects
    #
    # @example
    #
    #
    #   class UserAttributes
    #     include ROM::Model::Attributes
    #
    #     attribute :name
    #
    #     validates :name, presence: true
    #   end
    #
    #   class UserValidator
    #     include ROM::Model::Validator
    #   end
    #
    #   attrs = UserAttributes.new(name: '')
    #   UserValidator.call(attrs) # raises ValidationError
    #
    # @api public
    module Validator
      # Inclusion hook that extends a class with required interfaces
      #
      # @api private
      def self.included(base)
        base.class_eval do
          extend ClassMethods
          extend ROM::ClassMacros

          include ActiveModel::Validations
          include Equalizer.new(:attributes, :errors)

          base.defines :embedded_validators

          embedded_validators({})
        end
      end

      # @return [Model::Attributes]
      #
      # @api private
      attr_reader :attributes

      delegate :model_name, to: :attributes

      # @api private
      def initialize(attributes)
        @attributes = attributes
      end

      # @return [Model::Attributes]
      #
      # @api public
      def to_model
        attributes
      end

      # Trigger validations and return attributes on success
      #
      # @raises ValidationError
      #
      # @return [Model::Attributes]
      #
      # @api public
      def call
        raise ValidationError, errors unless valid?
        attributes
      end

      private

      # This is needed for ActiveModel::Validations to work properly
      # as it expects the object to provide attribute values. Meh.
      #
      # @api private
      def method_missing(name, *args, &block)
        attributes.fetch(name) { super }
      end

      module ClassMethods
        # Set relation name for a validator
        #
        # This is needed for validators that require database access
        #
        # @example
        #
        #   class UserValidator
        #     include ROM::Model::Validator
        #
        #     relation :users
        #
        #     validates :name, uniqueness: true
        #   end
        #
        # @return [Symbol]
        #
        # @api public
        def relation(name = nil)
          @relation = name if name
          @relation
        end

        # @api private
        def set_model_name(name)
          class_eval <<-RUBY
            def self.model_name
              @model_name ||= ActiveModel::Name.new(self, nil, #{name.inspect})
            end
          RUBY
        end

        # Trigger validation for specific attributes
        #
        # @param [Model::Attributes] attributes The attributes for validation
        #
        # @raises [ValidationError]
        #
        # @return [Model::Attributes]
        def call(attributes)
          validator = new(attributes)
          validator.call
        end

        # Specify an embedded validator for nested structures
        #
        # @api public
        def embedded(name, &block)
          validator_class = Class.new { include ROM::Model::Validator }
          validator_class.class_eval(&block)
          validator_class.set_model_name(name.to_s.classify)

          embedded_validators[name] = validator_class

          validate do
            value = attributes[name]

            validator = validator_class.new(value)
            validator.validate

            if validator.errors.any?
              self.errors.add(name, validator.errors)
            end
          end
        end
      end
    end
  end
end
