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
          file 'users.rb' do
            contains <<-CONTENT.strip_heredoc
              ROM.commands(:users) do

                define(:create) do
                  result :one
                end

                define(:update) do
                  result :one
                end

                define(:delete) do
                  result :one
                end

              end
            CONTENT
          end
        end
      end
    }
  end
end
