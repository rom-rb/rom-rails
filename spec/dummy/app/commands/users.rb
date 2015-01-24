ROM.commands(:users) do
  define(:create) do
    input UserForm.params
    validator UserForm.validator
    result :one
  end

  define(:delete) do
    result :one
  end
end
