class UpdateUserForm < UserForm
  commands users: :update

  attributes.timestamps(:updated_at)

  def commit!
    users.try { users.update.by_id(id).set(attributes) }
  end
end
