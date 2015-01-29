class CreateUser < ROM::Command
  relation :users
  type :create
  input UserForm.params
  validator UserForm.validator
  result :one
end

class DeleteUser < ROM::Command
  relation :users
  type :delete
  result :one
end
