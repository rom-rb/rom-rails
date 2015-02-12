require 'spec_helper'

require 'generators/rom/commands_generator'

describe ROM::Generators::CommandsGenerator do
  destination File.expand_path('../../../../tmp', __FILE__)

  before(:each) do
    prepare_destination
  end

  specify do
    run_generator ['users']

    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'commands' do
          directory 'users' do
            file 'create.rb' do
              contains <<-CONTENT.strip_heredoc
                class UserCommands::Create < ROM::Commands::Create
                  relation :users
                  register_as :create
                  result :one

                  # define a validator to use
                  # validator UserValidator
                end
              CONTENT
            end

            file 'update.rb' do
              contains <<-CONTENT.strip_heredoc
                class UserCommands::Update < ROM::Commands::Update
                  relation :users
                  register_as :update
                  result :one

                  # define a validator to use
                  # validator UserValidator
                end
              CONTENT
            end

            file 'delete.rb' do
              contains <<-CONTENT.strip_heredoc
                class UserCommands::Delete < ROM::Commands::Delete
                  relation :users
                  register_as :delete
                  result :one
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
    expect(create).to include("class UserCommands::Create < ROM::Commands::Create[:memory]")

    update = File.read(File.join(destination_root, 'app', 'commands', 'users', 'update.rb'))
    expect(update).to include("class UserCommands::Update < ROM::Commands::Update[:memory]")

    delete = File.read(File.join(destination_root, 'app', 'commands', 'users', 'delete.rb'))
    expect(delete).to include("class UserCommands::Delete < ROM::Commands::Delete[:memory]")
  end


end
