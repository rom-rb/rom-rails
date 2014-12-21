class UserParams
  include ROM::Model::Params

  attribute :name, String

  validates :name, presence: true
end
