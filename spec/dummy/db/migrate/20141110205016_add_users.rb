ROM::SQL.migration do
  change do
    create_table(:users) do |t|
      primary_key :id
      String :name
      String :email
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
