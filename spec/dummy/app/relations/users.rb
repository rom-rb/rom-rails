Rails.application.config.rom.env.relations do

  register(:users) do

    def by_name(name)
      users.select { |user| user[:name] == name }
    end

  end

end
