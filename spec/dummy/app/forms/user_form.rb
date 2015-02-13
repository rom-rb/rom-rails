class UserForm < ROM::Model::Form
  input do
    set_model_name 'User'

    attribute :name, String
    attribute :email, String
  end

  validations do
    relation :users

    validates :name, :email, presence: true
    validates :email, uniqueness: true
  end
end
