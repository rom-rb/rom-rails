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
      class UniquenessValidator < ActiveModel::EachValidator
        attr_reader :relation

        def initialize(options)
          super
          @relation = ROM.env.relations[options[:class].relation]
        end

        def validate_each(validator, name, value)
          validator.errors.add(name, :taken) unless unique?(name, value)
        end

        def unique?(name, value)
          relation.where(name => value).count.zero?
        end
      end

      def self.included(base)
        base.class_eval do
          extend ClassMethods
          include ActiveModel::Validations
        end
      end

      attr_reader :params

      def initialize(params)
        @params = params
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

        def call(params)
          validator = new(params)
          validator.call
        end
      end
    end
  end
end
