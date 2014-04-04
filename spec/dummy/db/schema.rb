env = Dummy::Application.config.rom.env

env.schema do
  base_relation(:users) do
    repository :default

    attribute :id, Integer
    attribute :name, String

    key :id
  end
end

env.mapping do
  relation(:users) do
    model User
    map :id, :name
  end
end

Dummy::Application.config.db = env.finalize
