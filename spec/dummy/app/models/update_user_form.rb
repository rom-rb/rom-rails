class UpdateUserForm < UserForm
  commands users: :update

  params.timestamps(:updated_at)

  def commit!
    users.try { |command| command.update(:by_id, id).set(params) }
  end
end
