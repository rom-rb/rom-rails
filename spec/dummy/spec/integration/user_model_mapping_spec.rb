require 'spec_helper'

describe 'User model mapping' do
  let(:rom) { ROM.env }

  let(:users) { rom.relation(:users).as(:users) }

  before do
    rom.relations.users.insert(name: 'Piotr', email: 'piotr@test.com')
  end

  it 'works' do
    piotr = User.new(id: 1, name: 'Piotr')

    expect(users.by_name('Piotr').to_a).to eql([piotr])
  end
end
