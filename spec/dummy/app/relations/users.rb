setup = Rails.application.config.rom.setup

setup.relation(:users) do

  def by_name(name)
    where(name: name)
  end

end
