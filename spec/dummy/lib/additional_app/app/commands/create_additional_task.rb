class CreateAdditionalTask < ROM::Commands::Create[:sql]
  relation :tasks
  register_as :create_additional
  result :one
end
