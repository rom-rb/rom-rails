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
      VirtusModel = Virtus.model(nullify_blank: true)

      # Inclusion hook used to extend a class with required interfaces
      #
      # @api private
      def self.included(base)
        base.class_eval do
          include VirtusModel
          include ActiveModel::Conversion
        end
        base.extend(ClassMethods)
      end

      # Return model name for the attributes class
      #
      # The model name object is configurable using `set_model_name` macro
      #
      # @see ClassMethods#set_model_name
      #
      # @return [ActiveModel::Name]
      #
      # @api public
      def model_name
        self.class.model_name
      end

      # @api private
      def fetch(name)
        if self.class.attribute_set[name]
          self[name]
        else
          raise KeyError, "#{name.inspect} is an unknown attribute name"
        end
      end

      # Class extensions for an attributes class
      #
      # @api public
      module ClassMethods
        # Default timestamp attribute names used by `timestamps` method
        DEFAULT_TIMESTAMPS = [:created_at, :updated_at].freeze

        # Process input and return attributes instance
        #
        # @example
        #   class UserAttributes
        #     include ROM::Model::Attributes
        #
        #     attribute :name, String
        #   end
        #
        #   UserAttributes[name: 'Jane']
        #
        # @param [Hash,#to_hash] input The input params
        #
        # @return [Attributes]
        #
        # @api public
        def [](input)
          input.is_a?(self) ? input : new(input)
        end

        # Macro for defining ActiveModel::Name object on the attributes class
        #
        # This is essential for rails helpers to work properly when generating
        # form input names etc.
        #
        # @example
        #   class UserAttributes
        #     include ROM::Model::Attributes
        #
        #     set_model_name 'User'
        #   end
        #
        # @return [undefined]
        #
        # @api public
        def set_model_name(name)
          class_eval <<-RUBY
            def self.model_name
              @model_name ||= ActiveModel::Name.new(self, nil, #{name.inspect})
            end
          RUBY
        end

        # Shortcut for defining timestamp attributes like created_at etc.
        #
        # @example
        #   class NewPostAttributes
        #     include ROM::Model::Attributes
        #
        #     # provide name(s) explicitly
        #     timestamps :published_at
        #
        #     # defaults to :created_at, :updated_at without args
        #     timestamps
        #   end
        #
        # @api public
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
