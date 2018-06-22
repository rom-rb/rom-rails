class CreateUser < ROM::Commands::Create[:sql]
  relation :users
  register_as :create
  result :one

  use :timestamps

  timestamp :created_at
end
