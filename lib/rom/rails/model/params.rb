require 'virtus'
require 'active_model/conversion'

module ROM
  module Model
    class ValidationError < CommandError
      attr_reader :params, :messages

      def initialize(params, errors)
        @params = params
        @messages = errors
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
      VirtusModel = Virtus.model(strict: true, required: false)

      def self.included(base)
        base.class_eval do
          include VirtusModel
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
  end
end
