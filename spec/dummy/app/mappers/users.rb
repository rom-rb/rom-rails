Rails.application.config.rom.env.mappers do
  define(:users) do
    model User

    attribute :id
    attribute :name
  end
end
