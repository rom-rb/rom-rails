module ROM
  module Model
    class Form
      module DSL
        attr_reader :attributes, :validator, :self_commands, :injectible_commands,
          :model, :input_block, :validations_block

        def inherited(klass)
          klass.inject_commands_for(*injectible_commands) if injectible_commands
          klass.commands(*self_commands) if self_commands
          klass.input(readers: false, &input_block) if input_block
          klass.validations(&validations_block) if validations_block
          super
        end

        def commands(names)
          names.each { |relation, _action| attr_reader(relation) }
          @self_commands = names
          self
        end

        def key(*keys)
          if keys.any? && !@key
            @key = keys
            attr_reader(*keys)
          elsif !@key
            @key = [:id]
            attr_reader :id
          elsif keys.any?
            @key = keys
          end
          @key
        end

        def input(options = {}, &block)
          readers = options.fetch(:readers) { true }
          define_attributes!(block)
          define_attribute_readers! if readers
          define_model!
          self
        end

        def validations(&block)
          define_validator!(block)
          self
        end

        def inject_commands_for(*names)
          @injectible_commands = names
          names.each { |name| attr_reader(name) }
          self
        end

        def build(input = {}, options = {})
          new(clear_input(input), options.merge(command_registry))
        end

        def command_registry
          @command_registry ||= setup_command_registry
        end

        def clear_input(input)
          hash = input.each_with_object({}) { |(key, value), object|
            next if value.is_a?(String) && value.blank?

            object[key] =
              if value.is_a?(Hash)
                clear_input(value)
              elsif value.is_a?(Array)
                value.map { |v| v.is_a?(Hash) ? clear_input(v) : v }
              else
                value
              end
          }
          ActiveSupport::HashWithIndifferentAccess.new(hash)
        end

        def define_attributes!(block)
          @input_block = block
          @attributes = ClassBuilder.new(name: "#{name}::Attributes", parent: Object).call { |klass|
            klass.send(:include, ROM::Model::Attributes)
          }
          @attributes.class_eval(&block)
          const_set(:Attributes, @attributes)
        end

        def define_attribute_readers!
          @attributes.attribute_set.each do |attribute|
            if public_instance_methods.include?(attribute.name)
              raise(
                ArgumentError,
                "#{attribute.name} attribute is in conflict with #{self}##{attribute.name}"
              )
            end

            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{attribute.name}
                attributes[:#{attribute.name}]
              end
            RUBY
          end
        end

        def define_model!
          @model = ClassBuilder.new(name: "#{name}::Model", parent: @attributes).call { |klass|
            klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def persisted?
                to_key.any?
              end

              def to_key
                to_h.values_at(#{key.map(&:inspect).join(', ')}).compact
              end
            RUBY
          }
          key.each { |name| @model.attribute(name) }
          const_set(:Model, @model)
        end

        def define_validator!(block)
          @validations_block = block
          @validator = ClassBuilder.new(name: "#{name}::Validator", parent: Object).call { |klass|
            klass.send(:include, ROM::Model::Validator)
          }
          @validator.class_eval(&block)
          const_set(:Validator, @validator)
        end

        private

        def rom
          ROM.env
        end

        def adapter
          ROM.adapters.keys.first
        end

        def setup_command_registry
          commands = {}

          if self_commands
            self_commands.each do |rel_name, name|
              command = build_command(name, rel_name)
              commands[rel_name] = CommandRegistry.new(name => command)
            end
          end

          if injectible_commands
            injectible_commands.each do |relation|
              commands[relation] = rom.command(relation)
            end
          end

          commands
        end

        def build_command(name, rel_name)
          klass = Command.build_class(name, rel_name, adapter: adapter)

          klass.result :one
          klass.validator @validator

          relation = rom.relations[rel_name]
          repository = rom.repositories[relation.repository]
          repository.extend_command_class(klass, relation.dataset)

          klass.build(relation)
        end
      end
    end
  end
end
