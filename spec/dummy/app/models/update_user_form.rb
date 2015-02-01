class UpdateUserForm < UserForm
  params.timestamps(:updated_at)

  def commit!
    users.try { |command| command.update(:by_id, id).set(params) }
  end
end
