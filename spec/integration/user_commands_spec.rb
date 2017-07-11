require 'spec_helper'

describe 'User commands' do
  subject(:users) { rom.commands[:users] }

  describe 'delete' do
    it 'deletes record' do
      relation = rom.relations[:users]
      relation.insert(name: 'Piotr', email: 'piotr@test.com')

      expect{ 
        users.delete.by_name('Piotr').call
      }.to change(relation, :count).by(-1)
    end
  end
end
