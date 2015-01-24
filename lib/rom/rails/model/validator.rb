require 'rom/rails/model/validator/uniqueness_validator'

module ROM
  module Model
    # Mixin for ROM-compliant validator objects
    #
    # @example
    #
    #
    #   class UserParams
    #     include ROM::Model::Params
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
    #   params = UserParams.new(name: '')
    #   UserValidator.call(params) # raises ValidationError
    #
    # @api public
    module Validator
      def self.included(base)
        base.class_eval do
          extend ClassMethods
          include ActiveModel::Validations
          include Equalizer.new(:params, :errors)
        end
      end

      attr_reader :params

      def initialize(params)
        @params = params
      end

      def to_model
        params
      end

      def model_name
        params.model_name
      end

      def call
        raise ValidationError.new(errors) unless valid?
        params
      end

      private

      def method_missing(name)
        params[name]
      end

      module ClassMethods
        def relation(name = nil)
          @relation = name if name
          @relation
        end

        def model_name
          params.model_name
        end

        def call(params)
          validator = new(params)
          validator.call
        end
      end
    end
  end
end
