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
      def self.included(base)
        base.class_eval do
          extend ClassMethods
          include ActiveModel::Validations
          include Equalizer.new(:attributes, :errors)
        end
      end

      attr_reader :attributes
      delegate :model_name, to: :attributes

      def initialize(attributes)
        @attributes = attributes
      end

      def to_model
        attributes
      end

      def call
        raise ValidationError, errors unless valid?
        attributes
      end

      private

      def method_missing(name)
        attributes[name]
      end

      module ClassMethods
        def relation(name = nil)
          @relation = name if name
          @relation
        end

        def model_name
          attributes.model_name
        end

        def call(attributes)
          validator = new(attributes)
          validator.call
        end
      end
    end
  end
end
