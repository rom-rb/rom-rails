require 'active_model'
class UserForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :email, :id

  validates :name, :email, presence: true

  def initialize(params = {})
    @id     = params[:id]
    @name   = params[:name]
    @email  = params[:email]
  end

  def to_h
    { name: name, email: email }
  end

  def merge(input)
    @name  = input[:name]
    @email = input[:email]

    self
  end

  def persisted?
    !!id
  end

  def self.model_name
    ActiveModel::Name.new(User)
  end

end
