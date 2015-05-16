module ROM
  module Model
    class Form
      # Proxy for form errors
      #
      # This simple proxy forwards most messages to a wrapped
      # ActiveModel::Errors object
      #
      # @api private
      class ErrorProxy < SimpleDelegator

        # @api private
        def initialize
          super ActiveModel::Errors.new([])
        end

        # update the current errors
        #
        # @param error [ActiveModel::Errors, ROM::Model::ValidatonError, object]
        #
        # When the argument is an AM Error object, or our wrapper around one,
        # replace the wrapped object.  Otherwise, add an error to the current
        # messages
        #
        # @return [self]
        #
        # @api private
        def set(error)
          case error
          when ActiveModel::Errors
            __setobj__ error
          when ROM::Model::ValidationError
            __setobj__ error.errors
          when nil
            # do nothing
          else
            add(:base, "a database error prevented saving this form")
          end

          self
        end

        # Has the command succeeded?
        #
        # @return [Boolean]
        #
        # @api public
        def success?
          !present?
        end

      end

    end
  end
end
