require 'spec_helper'

describe 'Params validation' do
  it 'works' do
    setup = ROM.setup('sqlite::memory')

    setup.default.adapter.connection.create_table(:users) do
      primary_key :id
      String :name
      String :email
    end

    rom = ROM.finalize.env

    class UserParams
      include ROM::Model::Params

      attribute :name, String
      attribute :email, String
    end

    class UserValidator
      include ROM::Model::Validator

      relation :users

      validates :name, presence: true
      validates :email, uniqueness: true
    end

    params = UserParams.new(name: 'Jane', email: 'jane@doe.org')
    validator = UserValidator.new(params)

    expect(validator.call).to be(params)

    rom.relations.users.insert(name: 'Jane', email: 'jane@doe.org')

    expect(validator).to_not be_valid
    expect(validator.errors[:email]).to eql(['has already been taken'])

    expect { validator.call }.to raise_error(
      ROM::Model::ValidationError
    )
  end
end
