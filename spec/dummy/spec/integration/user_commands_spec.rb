require 'spec_helper'

describe 'User commands' do
  subject(:users) { rom.command(:users) }

  describe 'create' do
    it 'inserts user with valid params' do
      result = users.try { create(name: 'Jade') }

      expect(result.value).to eql(id: 1, name: 'Jade')
    end

    it 'returns error if params are not valid' do
      result = users.try { create(name: '') }

      expect(result.value).to be(nil)
      expect(result.error).to be_instance_of(ROM::Model::ValidationError)
      expect(result.error.messages[:name]).to include("can't be blank")
    end
  end
end
