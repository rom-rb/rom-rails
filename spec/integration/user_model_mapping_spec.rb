require 'spec_helper'

describe 'User model mapping' do
  let(:rom) { ROM.env }

  let(:users) { rom.relations[:users].map_with(:user) }

  before do
    rom.relations.users.insert(name: 'Piotr', email: 'piotr@test.com')
  end

  it 'works' do
    piotr = User.new(id: 1, name: 'Piotr', email: 'piotr@test.com')

    expect(users.by_name('Piotr').to_a).to eql([piotr])
  end
end
