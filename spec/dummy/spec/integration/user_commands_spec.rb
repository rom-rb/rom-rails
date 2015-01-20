require 'spec_helper'

describe 'User commands' do
  subject(:users) { rom.command(:users) }

  describe 'create' do
    it 'inserts user with valid params' do
      result = users.try { create(name: 'Jade', email: 'jade@doe.org') }

      expect(result.value).to eql(
        id: result.value[:id], name: 'Jade', email: 'jade@doe.org'
      )
    end

    it 'returns error if params are not valid' do
      result = users.try { create(name: '') }

      expect(result.value).to be(nil)
      expect(result.error).to be_instance_of(ROM::Model::ValidationError)
      expect(result.error[:name]).to include("can't be blank")
    end
  end

  describe 'delete' do
    it 'deletes record' do
      users.create.call(name: 'Piotr', email: 'piotr@test.com')
      result = users.try { delete(:by_name, 'Piotr') }

      expect(result.error).to be(nil)
    end
  end
end
