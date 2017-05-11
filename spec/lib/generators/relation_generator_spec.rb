require 'generators/rom/relation_generator'

describe ROM::Generators::RelationGenerator, type: :generator do
  destination File.expand_path('../../../../tmp', __FILE__)

  before(:each) do
    prepare_destination
  end

  specify do
    run_generator ['users']
    default_adapter = ROM.adapters.keys.first

    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'relations' do
          file 'users_relation.rb' do
            contains <<-CONTENT.strip_heredoc
              class UsersRelation < ROM::Relation[:#{default_adapter}]
                # gateway :default

                dataset :users

                register_as :users

                # define your methods here ie:
                #
                # def all
                #   select(:id, :name).order(:id)
                # end
              end
            CONTENT
          end
        end
      end
    }
  end

  specify "with given adapter" do
    run_generator ['users', '--adapter=memory']

    relation = File.read(File.join(destination_root, 'app', 'relations', 'users_relation.rb'))
    expect(relation).to include("class UsersRelation < ROM::Relation[:memory]")
  end

  specify "with given gateway" do
    run_generator ['users', '--gateway=remote']

    relation = File.read(File.join(destination_root, 'app', 'relations', 'users_relation.rb'))
    expect(relation).to include("gateway :remote")
  end

  specify "with given registration" do
    run_generator ['users', '--register=profiles']

    relation = File.read(File.join(destination_root, 'app', 'relations', 'users_relation.rb'))
    expect(relation).to include("register_as :profiles")
  end
end
