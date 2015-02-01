class CreateUser < ROM::Commands::Create[:sql]
  relation :users
  register_as :create
  input NewUserForm.params
  validator NewUserForm.validator
  result :one
end

class UpdateUser < ROM::Commands::Update[:sql]
  relation :users
  register_as :update
  input UpdateUserForm.params
  validator UpdateUserForm.validator
  result :one
end

class DeleteUser < ROM::Commands::Delete[:sql]
  relation :users
  register_as :delete
  result :one
end
