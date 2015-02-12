require 'spec_helper'

require 'generators/rom/commands_generator'

describe ROM::Generators::CommandsGenerator do
  destination File.expand_path('../../../../tmp', __FILE__)

  before(:all) do
    prepare_destination
    run_generator ['users']
  end

  specify do
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
end
