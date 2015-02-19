require 'spec_helper'

require 'generators/rom/form_generator'

describe ROM::Generators::FormGenerator do
  destination File.expand_path('../../../../tmp', __FILE__)

  before(:each) do
    prepare_destination
  end

  specify "a create form" do
    run_generator ['users', '--command=create']

    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'forms' do
          file 'new_user_form.rb' do
            contains <<-CONTENT.strip_heredoc
              class NewUserForm < ROM::Model::Form
                commands users: :create

                input do
                  set_model_name 'User'

                  # define form input attributes
                  # attribute :name, String

                  timestamps
                end

                validations do
                  relation :users

                  # Add form validations
                  # validates :name, presence: true
                end

                def commit!
                  users.try { users.create.call(params) }
                end

              end
            CONTENT
          end
        end
      end
    }
  end

  specify "an edit form" do
    run_generator ['users', '--command=update']

    expect(destination_root).to have_structure {
      directory 'app' do
        directory 'forms' do
          file 'edit_user_form.rb' do
            contains <<-CONTENT.strip_heredoc
              class EditUserForm < ROM::Model::Form
                commands users: :update

                input do
                  set_model_name 'User'

                  # define form input attributes
                  # attribute :name, String

                  timestamps :updated_at
                end

                validations do
                  relation :users

                  # Add form validations
                  # validates :name, presence: true
                end

                def commit!
                  users.try { users.update.by_id(id).set(params) }
                end

              end
            CONTENT
          end
        end
      end
    }
  end
end
