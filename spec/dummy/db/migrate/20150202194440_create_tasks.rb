ROM::SQL.migration do
  change do
    create_table(:tasks) do
      primary_key :id
      String :title
    end
  end
end
