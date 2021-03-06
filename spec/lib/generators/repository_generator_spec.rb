require 'rom-repository'
require 'generators/rom/repository_generator'

RSpec.describe ROM::Generators::RepositoryGenerator, type: :generator do
  destination File.expand_path('../../../tmp', __dir__)

  before(:each) do
    prepare_destination
  end

  specify do
    run_generator ['users']

    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'repositories' do
          file 'user_repository.rb' do
            contains <<-CONTENT.strip_heredoc
              class UserRepository < ROM::Repository::Root
                root :users

                commands :create, update: :by_pk, delete: :by_pk

                struct_namespace Dummy

                def by_id(id)
                  root.by_pk(id).one
                end

                def all
                  root.to_a
                end
              end
            CONTENT
          end
        end
      end
    }
  end

  specify 'when generator has a compund name' do
    run_generator ['user_profiles']

    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'repositories' do
          file 'user_profile_repository.rb' do
            contains <<-CONTENT.strip_heredoc
              class UserProfileRepository < ROM::Repository::Root
                root :user_profiles

                commands :create, update: :by_pk, delete: :by_pk

                struct_namespace Dummy

                def by_id(id)
                  root.by_pk(id).one
                end

                def all
                  root.to_a
                end
              end
            CONTENT
          end
        end
      end
    }
  end
end
