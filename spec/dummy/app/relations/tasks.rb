class Tasks < ROM::Relation[:sql]
  schema(:tasks, infer: true)

  def by_id(id)
    where(id: id)
  end

  def all
    select(:id, :title).order(:id)
  end
end
