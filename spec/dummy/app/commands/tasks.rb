class CreateTask < ROM::Commands::Create[:sql]
  relation :tasks
  register_as :create
  result :one
end
