require 'spec_helper'

require 'generators/rom/relation_generator'

describe ROM::Generators::RelationGenerator do
  destination File.expand_path('../../../../tmp', __FILE__)

  before(:all) do
    prepare_destination
    run_generator ['users']
  end

  specify do
    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'relations' do
          file 'users.rb' do
            contains <<-CONTENT.strip_heredoc
              class Users < ROM::Relation
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
end
