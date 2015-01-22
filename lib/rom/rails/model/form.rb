require 'rom/rails/model/form/dsl'

module ROM
  module Model
    class Form
      extend Form::DSL

      attr_reader :params, :model, :result

      delegate :model_name, :persisted?, to: :model
      alias_method :to_model, :model

      def initialize(params = {}, options = {})
        @params = params
        @model = self.class.model.new(params.merge(options.slice(*self.class.key)))
        @result = nil
        options.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      end

      def commit!
        raise NotImplementedError
      end

      def save(*args)
        @result = commit!(*args)
        self
      end

      def success?
        errors.nil?
      end

      def errors
        result && result.error
      end
    end
  end
end