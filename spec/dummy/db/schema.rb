Dummy::Application.config.rom.env.schema do
  base_relation(:users) do
    repository :default

    attribute :id, Integer
    attribute :name, String

    key :id
  end
end

Dummy::Application.config.rom.env.mapping do
  users do
    map :id, :name
    model User
  end
end
