class UserMapper < ROM::Mapper
  relation :users

  model User

  attribute :id
  attribute :name
end
