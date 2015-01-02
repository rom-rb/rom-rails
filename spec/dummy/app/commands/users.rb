ROM.commands(:users) do
  define(:create) do
    input UserParams
    validator UserValidator
    result :one
  end

  define(:delete) do
    result :one
  end
end
