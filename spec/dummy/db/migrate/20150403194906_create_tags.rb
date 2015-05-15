ROM::SQL.migration do
  change do
    create_table(:tags) do |t|
      primary_key :id
      String :name
    end
  end
end
