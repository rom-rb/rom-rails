class Users < ROM::Relation[:sql]
  base_name :users

  def index
    order(:name)
  end

  def by_name(name)
    index.where(name: name)
  end
end
