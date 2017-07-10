class UserMapper < ROM::Mapper
  relation :users
  register_as :user

  model User

  attribute :id
  attribute :name
  attribute :email
  attribute :birthday
end
