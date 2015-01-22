module ROM
  module Model
    class Form
      module DSL
        attr_reader :params, :validator, :commands, :model

        def key(*key)
          if key.any? && !@key
            @key = key
            attr_reader key
          elsif !@key
            @key = [:id]
            attr_reader :id
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

          @model = ClassBuilder.new(name: "#{name}::Model", parent: @params).call { |klass|
            klass.class_eval do
              def persisted?
                !to_key.nil?
              end
            end
          }
          key.each { |name| @model.attribute(name) }

          self
        end

        def validations(&block)
          @validator = ClassBuilder.new(name: "#{name}::Validator", parent: Object).call { |klass|
            klass.send(:include, ROM::Model::Validator)
          }
          @validator.class_eval(&block)
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

        def rom
          ROM.env
        end
      end
    end
  end
end
