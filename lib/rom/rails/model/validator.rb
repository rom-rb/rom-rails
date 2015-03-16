require 'rom/rails/model/validator/uniqueness_validator'

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
          include ActiveModel::Validations
          include Equalizer.new(:attributes, :errors)
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
      def method_missing(name)
        attributes[name]
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

        # FIXME: this looks like not needed
        def model_name
          attributes.model_name
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
      end
    end
  end
end
