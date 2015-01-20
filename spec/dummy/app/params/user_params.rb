class UserParams
  include ROM::Model::Params

  attribute :name, String
  attribute :email, String

  param_key :user
end
