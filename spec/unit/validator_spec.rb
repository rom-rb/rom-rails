require 'spec_helper'

describe 'Validation' do
  subject(:validator) { user_validator.new(params) }

  let(:user_params) do
    Class.new {
      include ROM::Model::Params

      attribute :name, String
      attribute :email, String
    }
  end

  let(:user_validator) do
    Class.new {
      include ROM::Model::Validator

      relation :users

      validates :name, presence: true, uniqueness: { message: 'TAKEN!' }
      validates :email, uniqueness: true

      def self.name
        'UserValidator'
      end
    }
  end


  describe '#call' do
    let(:params) { {} }

    it 'raises validation error when params are not valid' do
      expect { validator.call }.to raise_error(ROM::Model::ValidationError)
    end
  end

  describe "#validate" do
    let(:params) { {} }

    it "sets errors when params are not valid" do
      validator.validate
      expect(validator.errors[:name]).to eql(["can't be blank"])
    end

  end

  describe ':presence' do
    let(:params) { user_params.new(name: '') }

    it 'sets error messages' do
      expect(validator).to_not be_valid
      expect(validator.errors[:name]).to eql(["can't be blank"])
    end
  end

  describe ':uniqueness' do
    let(:params) { user_params.new(name: 'Jane', email: 'jane@doe.org') }

    before do
      rom.relations.users.insert(name: 'Jane', email: 'jane@doe.org')
    end

    it 'sets default error messages' do
      expect(validator).to_not be_valid
      expect(validator.errors[:email]).to eql(['has already been taken'])
    end

    it 'sets custom error messages' do
      rom.relations.users.insert(name: 'Jane', email: 'jane@doe.org')

      expect(validator).to_not be_valid
      expect(validator.errors[:name]).to eql(['TAKEN!'])
    end
  end
end
