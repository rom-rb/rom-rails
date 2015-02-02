class NewUserForm < UserForm
  commands users: :create

  params.timestamps(:created_at)

  def commit!
    users.try { |command| command.create(params) }
  end
end
