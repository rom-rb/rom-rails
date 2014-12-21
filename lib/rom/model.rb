require 'virtus'
require 'active_model'

module ROM
  module Model
    class ValidationError < CommandError
      attr_reader :params, :messages

      def initialize(params)
        @params = params
        @messages = params.errors
      end
    end

    # Mixin for validatable and coercible parameters
    #
    # @example
    #
    #   class UserParams
    #     include ROM::Model::Params
    #
    #     attribute :email, String
    #     attribute :age, Integer
    #
    #     validates :email, :age, presence: true
    #   end
    #
    #   user_params = UserParams.new(email: '', age: '18')
    #
    #   user_params.email # => ''
    #   user_params.age # => 18
    #
    #   user_params.valid? # => false
    #   user_params.errors # => #<ActiveModel::Errors:0x007fd2423fadb0 ...>
    #
    # @api public
    module Params
      def self.included(base)
        base.class_eval do
          include Virtus.model
          include ActiveModel::Validations
          include ActiveModel::Conversion
        end
        base.extend(ClassMethods)
      end

      module ClassMethods
        def param_key(name)
          class_eval <<-RUBY
            def self.model_name
              @model_name ||= ActiveModel::Name.new(self, nil, #{name.to_s.inspect})
            end
          RUBY
        end

        def [](input)
          new(input)
        end
      end
    end

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
        base.extend(ClassMethods)
      end

      module ClassMethods
        def call(params)
          raise ValidationError.new(params) unless params.valid?
        end
      end
    end
  end
end
