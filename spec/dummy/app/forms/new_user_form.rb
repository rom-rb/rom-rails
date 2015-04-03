class NewUserForm < UserForm
  commands users: :create

  mappings users: :entity

  input do
    timestamps(:created_at)
  end

  def commit!
    users.try { users.create.call(attributes) }
  end
end
