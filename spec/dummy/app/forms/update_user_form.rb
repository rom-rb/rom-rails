class UpdateUserForm < UserForm
  commands users: :update

  params.timestamps(:updated_at)

  def commit!
    users.try { users.update.by_id(id).set(params) }
  end
end
