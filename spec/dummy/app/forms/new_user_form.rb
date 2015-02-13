class NewUserForm < UserForm
  commands users: :create

  params.timestamps(:created_at)

  def commit!
    users.try { users.create.call(params) }
  end
end
