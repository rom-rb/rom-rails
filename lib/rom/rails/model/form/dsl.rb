module ROM
  module Model
    class Form
      module DSL
        attr_reader :params, :validator, :commands, :model

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

        def input(&block)
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

          const_set(:Params, @params)

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

          self
        end

        def validations(&block)
          @validator = ClassBuilder.new(name: "#{name}::Validator", parent: Object).call { |klass|
            klass.send(:include, ROM::Model::Validator)
          }
          @validator.class_eval(&block)
          const_set(:Validator, @validator)
          self
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
          new(input, options.merge(commands))
        end

        private

        def rom
          ROM.env
        end
      end
    end
  end
end
