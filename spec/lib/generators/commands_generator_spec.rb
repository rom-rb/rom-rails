require 'generators/rom/commands_generator'

RSpec.describe ROM::Generators::CommandsGenerator do
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
          file 'create_user.rb' do
            contains <<-CONTENT.strip_heredoc
                  class CreateUser < ROM::Commands::Create[:#{default_adapter}]
                    relation :users
                    register_as :create
                    result :one

                    # set Timestamp plugin
                    # use :timestamps
                    # timestamp :created_at, :updated_at
                  end
            CONTENT
          end

          file 'update_user.rb' do
            contains <<-CONTENT.strip_heredoc
                  class UpdateUser < ROM::Commands::Update[:#{default_adapter}]
                    relation :users
                    register_as :update
                    result :one

                    # set Timestamp plugin
                    # use :timestamps
                    # timestamp :updated_at
                  end
            CONTENT
          end

          file 'delete_user.rb' do
            contains <<-CONTENT.strip_heredoc
                  class DeleteUser < ROM::Commands::Delete[:#{default_adapter}]
                    relation :users
                    register_as :delete
                    result :one

                  end
            CONTENT
          end
        end
      end
    }
  end

  specify "with given adapter" do
    run_generator ['users', '--adapter=memory']

    create = File.read(File.join(destination_root, 'app', 'commands', 'create_user.rb'))
    expect(create).to include("class CreateUser < ROM::Commands::Create[:memory]")

    update = File.read(File.join(destination_root, 'app', 'commands', 'update_user.rb'))
    expect(update).to include("class UpdateUser < ROM::Commands::Update[:memory]")

    delete = File.read(File.join(destination_root, 'app', 'commands', 'delete_user.rb'))
    expect(delete).to include("class DeleteUser < ROM::Commands::Delete[:memory]")
  end
end
