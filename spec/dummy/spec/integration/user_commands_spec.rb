require 'spec_helper'

describe 'User commands' do
  subject(:users) { rom.command(:users) }

  describe 'delete' do
    it 'deletes record' do
      rom.relations.users.insert(name: 'Piotr', email: 'piotr@test.com')
      result = users.try { delete(:by_name, 'Piotr') }

      expect(result.error).to be(nil)
    end
  end
end
