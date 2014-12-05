setup = Rails.application.config.rom.setup

setup.commands(:users) do

  define(:create) do
    result :one
  end

end
