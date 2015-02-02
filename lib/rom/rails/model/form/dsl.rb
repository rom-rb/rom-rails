module ROM
  module Model
    class Form
      module DSL
        attr_reader :params, :validator, :commands, :model,
          :input_block, :validations_block

        def inherited(klass)
          klass.inject_commands_for(*commands)
          klass.input(readers: false, &input_block) if input_block
          klass.validations(&validations_block) if validations_block
          super
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
          define_params!(block)
          define_attribute_readers! if readers
          define_model!
          self
        end

        def validations(&block)
          define_validator!(block)
        end

        def inject_commands_for(*names)
          @commands = names
          names.each { |name| attr_reader(name) }
          self
        end

        def build(input = {}, options = {})
          commands =
            if @commands
              self.commands.each_with_object({}) { |name, h|
                h[name] = rom.command(name)
              }
            else
              {}
            end
          new(clear_input(input), options.merge(commands))
        end

        def clear_input(input)
          input.each_with_object({}) { |(key, value), object|
            next if value.is_a?(String) && value.blank?

            object[key] =
              if value.kind_of?(Hash)
                clear_input(value)
              elsif value.kind_of?(Array)
                value.map { |v| v.kind_of?(Hash) ? clear_input(v) : v }
              else
                value
              end
          }.symbolize_keys
        end

        def define_params!(block)
          @input_block = block
          @params = ClassBuilder.new(name: "#{name}::Params", parent: Object).call { |klass|
            klass.send(:include, ROM::Model::Params)
          }
          @params.class_eval(&block)
          const_set(:Params, @params)
        end

        def define_attribute_readers!
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
        end

        def define_model!
          @model = ClassBuilder.new(name: "#{name}::Model", parent: @params).call { |klass|
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
      end
    end
  end
end
