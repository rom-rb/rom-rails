require 'rom-model'

require 'rom/rails/model/form/class_interface'
require 'rom/rails/model/form/error_proxy'

module ROM
  module Model
    # Abstract form class
    #
    # Form objects in ROM are your top-level interface to persist data in the
    # database. They combine many features that you know from ActiveRecord:
    #
    #   * params processing with sanitization and coercion
    #   * attribute validations
    #   * persisting data in the database
    #
    # The major difference is that a ROM form object separates those
    # responsibilities - a ROM form class has its own Attributes, Validator and
    # ROM commands that are accessible within its instance.
    #
    # @example
    #   class UserForm < ROM::Model::Form
    #     commands users: :create
    #
    #     input do
    #       set_model_name 'User'
    #
    #       attribute :name, String
    #     end
    #
    #     validations do
    #       validates :name, presence: true
    #     end
    #   end
    #
    #   class CreateUserForm < UserForm
    #     attributes.timestamps :created_at
    #
    #     def commit!
    #       users.try { users.create.call(attributes) }
    #     end
    #   end
    #
    #   # then in your controller
    #   CreateUserForm.build(params[:user]).save
    #
    # @api public
    class Form
      include Equalizer.new(:params, :model, :result)

      extend ROM::ClassMacros
      extend Form::ClassInterface

      defines :relation, :mappings

      # Return raw params received from the request
      #
      # @return [Object]
      #
      # @api public
      attr_reader :params

      # Return model instance representing an ActiveModel object that will be
      # persisted or updated
      #
      # @return [Object]
      #
      # @api public
      attr_reader :model

      # Return the result of commit!
      #
      # @return [Object]
      #
      # @api public
      attr_reader :result

      # Return any errors with the form
      #
      # @return [ErrorProxy]
      #
      # @api public
      attr_reader :errors

      delegate :model_name, :persisted?, :to_key, to: :model
      alias_method :to_model, :model

      class << self
        delegate :model_name, to: :attributes
      end

      # @api private
      def initialize(params = {}, options = {})
        @params = params
        @model  = self.class.model.new(params.merge(options.slice(*self.class.key)))
        @result = nil
        @errors = ErrorProxy.new
        options.each { |key, value| instance_variable_set("@#{key}", value) }
      end

      # A specialized form object must implement this method
      #
      # @abstract
      #
      # @api public
      def commit!
        raise NotImplementedError, "#{self.class}#commit! must be implemented"
      end

      # Save a form by calling commit! and memoizing result
      #
      # @return [self]
      #
      # @api public
      def save(*args)
        validate!
        @result = commit!(*args) if @errors.success?

        self
      end

      # Return whether commit was successful
      #
      # @return [TrueClass,FalseClass]
      #
      # @api public
      def success?
        errors.success?
      end

      # Trigger validation and store errors (if any)
      #
      # @api public
      def validate!
        @errors.clear
        return unless defined? self.class::Validator

        validator = self.class::Validator.new(attributes)
        validator.validate

        @errors.set validator.errors
      end

      # Sanitize and coerce input params
      #
      # This can also set default values
      #
      # @return [Model::Attributes]
      #
      # @api public
      def attributes
        self.class.attributes[params]
      end

    end
  end
end
