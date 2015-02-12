require 'spec_helper'

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
          file 'users.rb' do
            contains <<-CONTENT.strip_heredoc
              class Users < ROM::Relation[:#{default_adapter}]
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

    relation = File.read(File.join(destination_root, 'app', 'relations', 'users.rb'))
    expect(relation).to include("class Users < ROM::Relation[:memory]")
  end


end
