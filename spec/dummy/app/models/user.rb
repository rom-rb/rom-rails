class User
  include Equalizer.new(:id, :name, :email)

  attr_reader :id, :name, :email

  def initialize(attrs)
    @id, @name, @email = attrs.values_at(:id, :name, :email)
  end
end
