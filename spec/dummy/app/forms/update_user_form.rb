class UpdateUserForm < UserForm
  commands users: :update

  input do
    timestamps(:updated_at)
  end

  def commit!
    users.try { users.update.by_id(id).call(attributes) }
  end
end
