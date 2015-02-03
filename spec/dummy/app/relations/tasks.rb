class Tasks < ROM::Relation[:sql]
  def by_id(id)
    where(id: id)
  end

  def all
    select(:id, :title).order(:id)
  end
end
