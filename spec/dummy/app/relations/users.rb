Rails.application.config.rom.env.relations do

  register(:users) do

    def by_name(name)
      where(name: name)
    end

  end

end
