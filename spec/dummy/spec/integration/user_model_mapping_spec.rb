require 'spec_helper'

describe 'User model mapping' do
  it 'works' do
    users = Dummy::Application.config.rom.env[:users]

    piotr = User.new(id: 1, name: "Piotr")

    users.insert(piotr)

    expect(users.restrict(name: "Piotr").one).to eql(piotr)
  end
end
