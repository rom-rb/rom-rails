class UserForm < ROM::Model::Form
  inject_commands_for :users

  input do
    param_key :user

    attribute :name, String
    attribute :email, String
  end

  validations do
    relation :users

    validates :name, :email, presence: true
    validates :email, uniqueness: true
  end

  def commit!
    users.try { |command| command.create(params) }
  end
end
