require 'spec_helper'

describe 'User model mapping' do
  let(:rom) { Rails.application.config.rom.env }

  let(:users) { rom.read(:users) }

  before do
    rom.command(:users).try { create(name: 'Piotr') }
  end

  it 'works' do
    piotr = User.new(id: 1, name: 'Piotr')

    expect(users.by_name('Piotr').to_a).to eql([piotr])
  end
end
