class UpdateUser < ROM::Commands::Update[:sql]
  relation :users
  register_as :update
  result :one

  use :timestamps

  timestamp :updated_at
end
