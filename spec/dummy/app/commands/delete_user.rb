class DeleteUser < ROM::Commands::Delete[:sql]
  relation :users
  register_as :delete
  result :one
end
