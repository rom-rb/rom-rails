require 'generators/rom/mapper_generator'

RSpec.describe ROM::Generators::MapperGenerator do
  destination File.expand_path('../../../tmp', __dir__)

  before(:all) do
    prepare_destination
    run_generator ['users']
    run_generator ['app_user']
  end

  specify do
    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'mappers' do
          file 'user_mapper.rb' do
            contains <<-CONTENT.strip_heredoc
              class UserMapper < ROM::Mapper
                relation :users

                register_as :user

                # specify model and attributes ie
                #
                # model User
                #
                # attribute :name
                # attribute :email
              end
            CONTENT
          end

          file 'app_user_mapper.rb' do
            contains <<-CONTENT.strip_heredoc
              class AppUserMapper < ROM::Mapper
                relation :app_users

                register_as :app_user

                # specify model and attributes ie
                #
                # model AppUser
                #
                # attribute :name
                # attribute :email
              end
            CONTENT
          end
        end
      end
    }
  end
end
