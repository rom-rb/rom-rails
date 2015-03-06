class NewUserForm < UserForm
  commands users: :create

  attributes.timestamps(:created_at)

  def commit!
    users.try { users.create.call(attributes) }
  end
end
