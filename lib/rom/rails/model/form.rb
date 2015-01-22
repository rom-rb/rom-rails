module ROM
  module Model
    class Form
      class << self
        attr_reader :params, :validator, :commands, :model
      end

      def self.key(*key)
        if key.any? && !@key
          @key = key
          attr_reader key
        elsif !@key
          @key = [:id]
          attr_reader :id
        end
        @key
      end

      def self.input(&block)
        @params = ClassBuilder.new(name: "#{name}::Params", parent: Object).call { |klass|
          klass.send(:include, ROM::Model::Params)
        }
        @params.class_eval(&block)
        @params.attribute_set.each do |attribute|
          if public_instance_methods.include?(attribute.name)
            raise(
              ArgumentError,
              "#{attribute.name} attribute is in conflict with #{self}##{attribute.name}"
            )
          end

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attribute.name}
              params[:#{attribute.name}]
            end
          RUBY
        end

        @model = @params.clone
        @model.class_eval do
          def persisted?
            !to_key.nil?
          end
        end
        key.each { |name| @model.attribute(name) }

        self
      end

      def self.validations(&block)
        @validator = ClassBuilder.new(name: "#{name}::Validator", parent: Object).call { |klass|
          klass.send(:include, ROM::Model::Validator)
        }
        @validator.class_eval(&block)
        self
      end

      def self.inject_commands_for(*names)
        @commands = names
        names.each { |name| attr_reader(name) }
        self
      end

      def self.build(input = {}, options = {})
        commands =
          if @commands
            self.commands.each_with_object({}) { |name, h|
              h[name] = rom.command(name)
            }
          else
            {}
          end
        new(input, options.merge(commands))
      end

      def self.rom
        ROM.env
      end

      attr_reader :params, :result

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

      def to_model
        @model
      end
    end
  end
end
