rom = Rails.application.config.rom.env

rom.schema do
  base_relation(:users) do
    repository :default

    attribute :id
    attribute :name
  end
end
