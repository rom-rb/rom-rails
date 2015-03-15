require 'rom/rails/model/form/class_interface'

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

      defines :relation

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
        @errors =  ActiveModel::Errors.new([])
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
        @result = commit!(*args)
        self
      end

      # Return whether commit was successful
      #
      # @return [TrueClass,FalseClass]
      #
      # @api public
      def success?
        errors.nil? || !errors.any?
      end

      # Trigger validation and store errors (if any)
      #
      # @api public
      def validate!
        validator = self.class::Validator.new(attributes)
        validator.validate

        @errors = validator.errors
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

      # Return errors
      #
      # @return [ActiveModel::Errors]
      #
      # @api public
      def errors
        (result && result.error) || @errors
      end
    end
  end
end
