require 'spec_helper'

describe 'Validation' do
  subject(:validator) { user_validator.new(attributes) }

  let(:user_attrs) do
    Class.new {
      include ROM::Model::Attributes

      set_model_name 'User'

      attribute :name, String
      attribute :email, String
      attribute :birthday, Date
    }
  end

  let(:user_validator) do
    Class.new {
      include ROM::Model::Validator

      relation :users

      validates :name, presence: true, uniqueness: { message: 'TAKEN!' }
      validates :email, uniqueness: true

      def self.name
        'User'
      end
    }
  end

  describe '#call' do
    let(:attributes) { user_attrs.new }

    it 'raises validation error when attributes are not valid' do
      expect { validator.call }.to raise_error(ROM::Model::ValidationError)
    end
  end

  describe "#validate" do
    let(:attributes) { user_attrs.new }

    it "sets errors when attributes are not valid" do
      validator.validate
      expect(validator.errors[:name]).to eql(["can't be blank"])
    end
  end

  describe ':presence' do
    let(:attributes) { user_attrs.new(name: '') }

    it 'sets error messages' do
      expect(validator).to_not be_valid
      expect(validator.errors[:name]).to eql(["can't be blank"])
    end
  end

  describe ':uniqueness' do
    let(:attributes) { user_attrs.new(name: 'Jane', email: 'jane@doe.org') }

    it 'sets default error messages' do
      rom.relations.users.insert(name: 'Jane', email: 'jane@doe.org')

      expect(validator).to_not be_valid
      expect(validator.errors[:email]).to eql(['has already been taken'])
    end

    it 'sets custom error messages' do
      rom.relations.users.insert(name: 'Jane', email: 'jane@doe.org')

      expect(validator).to_not be_valid
      expect(validator.errors[:name]).to eql(['TAKEN!'])
    end

    context 'with unique attributes within a scope' do
      let(:user_validator) do
        Class.new {
          include ROM::Model::Validator

          relation :users

          validates :email, uniqueness: {scope: :name}

          def self.name
            'User'
          end
        }
      end

      let(:doubly_scoped_validator) do
        Class.new {
          include ROM::Model::Validator

          relation :users

          validates :email, uniqueness: {scope: [:name, :birthday]}

          def self.name
            'User'
          end
        }
      end

      it 'does not add errors' do
        rom.relations.users.insert(name: 'Jane', email: 'jane+doe@doe.org')
        attributes = user_attrs.new(name: 'Jane', email: 'jane@doe.org', birthday: Date.parse('2014-12-12'))
        validator = user_validator.new(attributes)
        expect(validator).to be_valid
      end

      it 'adds an error when the doubly scoped validation fails' do
        attributes = user_attrs.new(name: 'Jane', email: 'jane@doe.org', birthday: Date.parse('2014-12-12'))
        validator = doubly_scoped_validator.new(attributes)
        expect(validator).to be_valid

        rom.relations.users.insert(attributes.attributes)
        expect(validator).to_not be_valid

        attributes = user_attrs.new(name: 'Jane', email: 'jane+doe@doe.org', birthday: Date.parse('2014-12-12'))
        validator = doubly_scoped_validator.new(attributes)
        expect(validator).to be_valid
      end
    end

    describe 'with missing relation' do
      let(:user_validator) do
        Class.new {
          include ROM::Model::Validator

          validates :email, uniqueness: true

          def self.name
            'User'
          end
        }
      end

      it 'raises a helpful error' do
        validator = user_validator.new(user_attrs.new)
        expect {
          validator.valid?
        }.to raise_error(/relation must be specified/)
      end
    end
  end

  describe '#method_missing' do
    let(:attributes) { { name: 'Jane' } }

    it 'returns attribute value if present' do
      expect(validator.name).to eql('Jane')
    end

    it 'returns nil if attribute is not present' do
      expect(validator.email).to be(nil)
    end

    it 'raises error when name does not match any of the attributes' do
      expect { validator.foobar }.to raise_error(NoMethodError, /foobar/)
    end
  end
end
