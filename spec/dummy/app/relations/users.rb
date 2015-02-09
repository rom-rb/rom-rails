class Users < ROM::Relation[:sql]
  def by_id(id)
    where(id: id)
  end

  def index
    order(:name)
  end

  def by_name(name)
    index.where(name: name)
  end
end
