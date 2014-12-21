require 'virtus'
require 'active_model/naming'
require 'active_model/validations'

module ROM
  module Model
    class ValidationError < CommandError
      attr_reader :params, :messages

      def initialize(params)
        @params = params
        @messages = params.errors
      end
    end

    module Params
      def self.included(base)
        base.class_eval do
          include Virtus.model
          include ActiveModel::Naming
          include ActiveModel::Validations
        end
        base.extend(ClassMethods)
      end

      module ClassMethods
        def [](input)
          new(input)
        end
      end
    end

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
