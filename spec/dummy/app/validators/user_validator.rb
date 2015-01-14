class UserValidator
  include ROM::Model::Validator

  validates :name, presence: true
end
