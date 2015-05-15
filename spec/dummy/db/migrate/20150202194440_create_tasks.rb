ROM::SQL.migration do
  change do
    create_table(:tasks) do |t|
      primary_key :id
      String :title
    end
  end
end
