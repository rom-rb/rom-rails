class UserMapper < ROM::Mapper
  relation :users
  register_as :entity

  model User

  attribute :id
  attribute :name
  attribute :email
end
