ROM::SQL.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :name
      String :email
      Date   :birthday
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
