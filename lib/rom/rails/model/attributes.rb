require 'virtus'
require 'active_model/conversion'

module ROM
  module Model
    # Mixin for validatable and coercible parameters
    #
    # @example
    #
    #   class UserAttributes
    #     include ROM::Model::Attributes
    #
    #     attribute :email, String
    #     attribute :age, Integer
    #
    #     validates :email, :age, presence: true
    #   end
    #
    #   user_attrs = UserAttributes.new(email: '', age: '18')
    #
    #   user_attrs.email # => ''
    #   user_attrs.age # => 18
    #
    #   user_attrs.valid? # => false
    #   user_attrs.errors # => #<ActiveModel::Errors:0x007fd2423fadb0 ...>
    #
    # @api public
    module Attributes
      VirtusModel = Virtus.model(strict: true, required: false)

      def self.included(base)
        base.class_eval do
          include VirtusModel
          include ActiveModel::Conversion
        end
        base.extend(ClassMethods)
      end

      def model_name
        self.class.model_name
      end

      module ClassMethods
        DEFAULT_TIMESTAMPS = [:created_at, :updated_at].freeze

        def [](input)
          input.is_a?(self) ? input : new(input)
        end

        def set_model_name(name)
          class_eval <<-RUBY
            def self.model_name
              @model_name ||= ActiveModel::Name.new(self, nil, #{name.inspect})
            end
          RUBY
        end

        def timestamps(*attrs)
          if attrs.empty?
            DEFAULT_TIMESTAMPS.each do |t|
              attribute t, DateTime, default: proc { DateTime.now }
            end
          else
            attrs.each do |attr|
              attribute attr, DateTime, default: proc { DateTime.now }
            end
          end
        end
      end
    end
  end
end
