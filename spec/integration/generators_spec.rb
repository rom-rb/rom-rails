require 'spec_helper'

require 'generators/rom/rails/relation_generator'

describe ROM::Rails::RelationGenerator, type: :generator do
  destination File.expand_path('../../tmp', __FILE__)

  before(:all) do
    prepare_destination
    run_generator ['users']
  end

  specify do
    expect(destination_root).to have_structure do
      directory 'app' do
        directory 'relations' do
          file 'users.rb' do
            contains <<-RUBY
              ROM.relation(:users) do
                # define your methods here ie:
                #
                # def all
                #   select(:id, :name).order(:id)
                # end
                #
              end
            RUBY
          end
        end
      end
    end
  end
end
