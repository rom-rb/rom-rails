module ROM
  module Model
    class Form
      module ClassInterface
        # Return param handler class
        #
        # This class is used to process input params coming from a request and
        # it's being created using `input` API
        #
        # @example
        #
        #   class MyForm < ROM::Model::Form
        #     input do
        #       attribute :name, String
        #     end
        #   end
        #
        #   MyForm.attributes # => MyForm::Attributes
        #
        #   # process input params
        #   attributes = MyForm.attributes[name: 'Jane']
        #
        # @return [Class]
        #
        # @api public
        attr_reader :attributes

        # Return attributes validator
        #
        # @example
        #   class MyForm < ROM::Model::Form
        #     input do
        #       attribute :name, String
        #     end
        #
        #     validations do
        #       validates :name, presence: true
        #     end
        #   end
        #
        #   attributes = MyForm.attributes[name: nil]
        #   MyForm::Validator.call(attributes) # raises validation error
        #
        # @return [Class]
        #
        # @api public
        attr_reader :validator

        # Return model class
        #
        # @return [Class]
        #
        # @api public
        attr_reader :model

        # relation => command name mapping used to generate commands automatically
        #
        # @return [Hash]
        #
        # @api private
        attr_reader :self_commands

        # A list of relation names for which commands should be injected from
        # the rom env automatically.
        #
        # This is used only when a given form re-uses existing commands
        #
        # @return [Hash]
        #
        # @api private
        attr_reader :injectible_commands

        # Copy input attributes, validator and model to the descendant
        #
        # @api private
        def inherited(klass)
          klass.inject_commands_for(*injectible_commands) if injectible_commands
          klass.commands(*self_commands) if self_commands
          input_blocks.each { |block| klass.input(readers: false, &block) }
          validation_blocks.each { |block| klass.validations(&block) }
          super
        end

        # Set key for the model that is handled by a form object
        #
        # This defaults to [:id]
        #
        # @example
        #   class MyForm < ROM::Model::Form
        #     key [:user_id]
        #   end
        #
        # @return [Array<Symbol>]
        #
        # @api public
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

        # Specify what commands should be generated for a form object
        #
        # @example
        #   class MyForm < ROM::Model::Form
        #     commands users: :create
        #   end
        #
        # @param [Hash] relation => command name map
        #
        # @return [self]
        #
        # @api public
        def commands(names)
          names.each { |relation, _action| attr_reader(relation) }
          @self_commands = names
          self
        end

        # Specify input params handler class
        #
        # This uses Virtus DSL
        #
        # @example
        #   class MyForm < ROM::Model::Form
        #     input do
        #       set_model_name 'User'
        #
        #       attribute :name, String
        #       attribute :age, Integer
        #     end
        #   end
        #
        #   MyForm.build(name: 'Jane', age: 21).attributes
        #   # => #<MyForm::Attributes:0x007f821f863d48 @name="Jane", @age=21>
        #
        # @return [self]
        #
        # @api public
        def input(options = {}, &block)
          readers = options.fetch(:readers) { true }
          define_attributes!(block)
          define_attribute_readers! if readers
          define_model!
          self
        end

        # Specify attribute validator class
        #
        # This uses ActiveModel::Validations DSL
        #
        # @example
        #   class MyForm < ROM::Model::Form
        #     input do
        #       set_model_name 'User'
        #
        #       attribute :name, String
        #       attribute :age, Integer
        #     end
        #
        #     validations do
        #       validates :name, :age, presence: true
        #     end
        #   end
        #
        #   form = MyForm.build(name: 'Jane', age: nil)
        #   # => #<MyForm::Attributes:0x007f821f863d48 @name="Jane", @age=21>
        #   form.validate! # raises
        #
        # @return [self]
        #
        # @api public
        def validations(&block)
          define_validator!(block)
          self
        end

        # Inject specific commands from the rom env
        #
        # This can be used when the env has re-usable commands
        #
        # @example
        #   class MyForm < ROM::Model::Form
        #     inject_commands_for :users
        #   end
        #
        # @api public
        def inject_commands_for(*names)
          @injectible_commands = names
          names.each { |name| attr_reader(name) }
          self
        end

        # Build a form object using input params and options
        #
        # @example
        #   class MyForm < ROM::Model::Form
        #     input do
        #       set_model_name 'User'
        #
        #       attribute :name, String
        #       attribute :age, Integer
        #     end
        #   end
        #
        #   # form for a new object
        #   form = MyForm.build(name: 'Jane')
        #
        #   # form for a persisted object
        #   form = MyForm.build({ name: 'Jane' }, id: 1)
        #
        # @return [Model::Form]
        #
        # @api public
        def build(input = {}, options = {})
          commands =
            if mappings
              command_registry.each_with_object({}) { |(relation, registry), h|
                mapper = mappings[relation]

                h[relation] =
                  if mapper
                    registry.as(mapper)
                  else
                    registry
                  end
              }
            else
              command_registry
            end
          new(input, options.merge(commands))
        end

        private

        # retrieve a list of reserved method names
        #
        # @return [Array<Symbol>]
        #
        # @api private
        def reserved_attributes
          ROM::Model::Form.public_instance_methods
        end

        # @return [Hash<Symbol=>ROM::CommandRegistry>]
        #
        # @api private
        def command_registry
          @command_registry ||= setup_command_registry
        end

        # input block stored to be used in inherited hook
        #
        # @return [Proc]
        #
        # @api private
        def input_blocks
          @input_blocks ||= []
        end

        # validation blocks stored to be used in inherited hook
        #
        # @return [Proc]
        #
        # @api private
        def validation_blocks
          @validation_blocks ||= []
        end

        # Create attribute handler class
        #
        # @return [Class]
        #
        # @api private
        def define_attributes!(block)
          input_blocks << block
          @attributes = ClassBuilder.new(name: "#{name}::Attributes", parent: Object).call { |klass|
            klass.send(:include, ROM::Model::Attributes)
          }
          input_blocks.each do |input_block|
            @attributes.class_eval(&input_block)
          end

          update_const(:Attributes, @attributes)
        end

        # Define attribute readers for the form
        #
        # This is very unfortunate but rails `form_for` and friends require
        # the object to provide attribute values, hence we need to expose those
        # using the form object itself.
        #
        # @return [Class]
        #
        # @api private
        def define_attribute_readers!
          reserved = reserved_attributes
          @attributes.attribute_set.each do |attribute|
            if reserved.include?(attribute.name)
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

        # Create model class
        #
        # Model instance represents an entity that will be persisted or was
        # already persisted and will be updated.
        #
        # This object is returned via `Form#to_model` which rails uses internally
        # in many places to figure out what to do.
        #
        # Model object provides two crucial pieces of information: whether or not
        # something was persisted and its primary key value
        #
        # @return [Class]
        #
        # @api private
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

          update_const(:Model, @model)
        end

        # Define attribute validator class
        #
        # @return [Class]
        #
        # @api private
        def define_validator!(block)
          validation_blocks << block
          @validator = ClassBuilder.new(name: "#{name}::Validator", parent: Object).call { |klass|
            klass.send(:include, ROM::Model::Validator)
          }
          validation_blocks.each { |validation| @validator.class_eval(&validation) }
          update_const(:Validator, @validator)
        end

        # Shortcut to global ROM env
        #
        # @return [ROM::Env]
        #
        # @api private
        def rom
          ROM.env
        end

        # Return identifier of the default adapter
        #
        # TODO: we need an interface for that in ROM
        #
        # @return [Symbol]
        #
        # @api private
        def adapter
          ROM.adapters.keys.first
        end

        # Generate a command registry hash which will be auto-injected to a form
        # object.
        #
        # @return [Hash<Symbol=>ROM::CommandRegistry>]
        #
        # @api private
        def setup_command_registry
          commands = {}

          if self_commands
            self_commands.each do |rel_name, name|
              command = build_command(name, rel_name)
              elements = { name => command }
              options =
                if rom.mappers.key?(rel_name)
                  { mappers: rom.mappers[rel_name] }
                else
                  {}
                end

              commands[rel_name] = CommandRegistry.new(rel_name, elements, options)
            end
          end

          if injectible_commands
            injectible_commands.each do |relation|
              commands[relation] = rom.command(relation)
            end
          end

          commands
        end

        # Build a command object with a specific name
        #
        # @param [Symbol] name The name of the command
        # @param [Symbol] rel_name The name of the command's relation
        #
        # @return [ROM::Command]
        #
        # @api private
        def build_command(name, rel_name)
          klass = ConfigurationDSL::Command.build_class(name, rel_name, adapter: adapter)

          klass.result :one
          klass.validator @validator

          relation = rom.relations[rel_name]
          gateway = rom.gateways[relation.gateway]
          gateway.extend_command_class(klass, relation.dataset)

          klass.send(:include, Command.relation_methods_mod(relation.class))

          klass.build(relation)
        end

        # Silently update a constant, replacing any existing definition without
        # warning
        #
        # @param [Symbol] name the name of the constant
        # @param [Class] klass class to assign
        #
        # @api private
        def update_const(name, klass)
          remove_const(name) if const_defined?(name, false)
          const_set(name, klass)
        end
      end
    end
  end
end
