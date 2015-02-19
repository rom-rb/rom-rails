require 'spec_helper'

require 'generators/rom/commands_generator'

describe ROM::Generators::CommandsGenerator do
  destination File.expand_path('../../../../tmp', __FILE__)

  before(:each) do
    prepare_destination
  end

  specify do
    run_generator ['users']

    default_adapter = ROM.adapters.keys.first

    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'commands' do
          directory 'users' do
            file 'create.rb' do
              contains <<-CONTENT.strip_heredoc
                module UserCommands
                  class Create < ROM::Commands::Create[:#{default_adapter}]
                    relation :users
                    register_as :create
                    result :one

                    # define a validator to use
                    # validator UserValidator
                  end
                end
              CONTENT
            end

            file 'update.rb' do
              contains <<-CONTENT.strip_heredoc
                module UserCommands
                  class Update < ROM::Commands::Update[:#{default_adapter}]
                    relation :users
                    register_as :update
                    result :one

                    # define a validator to use
                    # validator UserValidator
                  end
                end
              CONTENT
            end

            file 'delete.rb' do
              contains <<-CONTENT.strip_heredoc
                module UserCommands
                  class Delete < ROM::Commands::Delete[:#{default_adapter}]
                    relation :users
                    register_as :delete
                    result :one
                  end
                end
              CONTENT
            end
          end
        end
      end
    }
  end

  specify "with given adapter" do
    run_generator ['users', '--adapter=memory']

    create = File.read(File.join(destination_root, 'app', 'commands', 'users', 'create.rb'))
    expect(create).to include("class Create < ROM::Commands::Create[:memory]")

    update = File.read(File.join(destination_root, 'app', 'commands', 'users', 'update.rb'))
    expect(update).to include("class Update < ROM::Commands::Update[:memory]")

    delete = File.read(File.join(destination_root, 'app', 'commands', 'users', 'delete.rb'))
    expect(delete).to include("class Delete < ROM::Commands::Delete[:memory]")
  end
end
