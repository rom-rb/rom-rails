require 'spec_helper'

describe 'Form' do
  subject(:form) do
    Class.new(ROM::Model::Form) do
      def self.name
        'UserForm'
      end

      input do
        set_model_name 'User'

        attribute :email, String
      end

      validations do
        validates :email, presence: true
      end

      def commit!(*args)
        "it works #{args.inspect}"
      end
    end
  end

  describe '.build' do
    it 'rejects blank strings from params' do
      input = { 'name'  => '' }

      form_object = form.build(input)

      expect(form_object.attributes.to_h).to eql(email: nil)
    end

    it 'exposes param values' do
      params = { 'email' => 'jane@doe.org' }
      form_object = form.build(params)
      expect(form_object.email).to eql('jane@doe.org')

      params = { email: 'jane@doe.org' }
      form_object = form.build(params)
      expect(form_object.email).to eql('jane@doe.org')
    end
  end

  describe '.commands' do
    it 'builds its own command registry' do
      form = Class.new(ROM::Model::Form) {
        inject_commands_for :tasks
        commands users: :create
        input { attribute :name }
        validations { validates :name, presence: true }

        def commit!
          users.try { users.create.call(attributes) }
        end
      }

      form_object = form.build(name: '').save

      expect(form_object).not_to be_success
      expect(form_object.errors[:name]).to include("can't be blank")
      expect(rom.relations.users.first).to be(nil)

      form_object = form.build(name: 'Jane').save

      expect(form_object).to be_success
      expect(rom.relations.users.first).to include(name: 'Jane')

      expect(form_object.tasks).to_not be(nil)
    end
  end

  describe '.key' do
    it 'returns default key' do
      expect(form.key).to eql([:id])
      expect(form.new({}, { id: 312 }).to_key).to eql([312])
    end

    it 'sets a custom composite key' do
      form = Class.new(ROM::Model::Form) do
        def self.name
          'UserForm'
        end

        key :foo_id, :bar_id

        input do
          set_model_name 'User'

          attribute :email, String
        end
      end

      expect(form.key).to eql([:foo_id, :bar_id])
      expect(form.new({}, { foo_id: 312, bar_id: 132 }).to_key).to eql([312, 132])
    end
  end

  describe '.model_name' do
    it 'delegates to Attributes.model_name' do
      expect(form.model_name).to be(form.attributes.model_name)
    end
  end

  describe 'input DSL' do
    it 'defines params handler' do
      expect(form.const_defined?(:Attributes)).to be(true)
      expect(form.attributes.attribute_set.map(&:name)).to eql([:email])
      expect(form.attributes.model_name).to eql('User')
    end

    it 'defines a model' do
      expect(form.const_defined?(:Model)).to be(true)
      expect(form.model.attribute_set.map(&:name)).to match_array([:id, :email])
    end

    it 'raises error when attribute is in conflict with form interface' do
      expect {
        Class.new(ROM::Model::Form) do
          input do
            attribute :commit!
          end
        end
      }.to raise_error(ArgumentError, /commit! attribute is in conflict/)
    end
  end

  describe 'validator DSL' do
    it 'defines validator' do
      expect(form.const_defined?(:Validator)).to be(true)

      expect(form.validator).not_to be(nil)

      expect { form.validator.call(email: 'jane@doe') }.not_to raise_error

      expect { form.validator.call(email: '') }.to raise_error(
        ROM::Model::ValidationError
      )
    end
  end

  describe '#model_name' do
    it 'delegates to model' do
      form_object = form.build
      expect(form_object.model_name).to be(form_object.model.model_name)
    end
  end

  describe '#persisted?' do
    it 'delegates to model' do
      form_object = form.build
      expect(form_object).not_to be_persisted
      expect(form_object.persisted?).to be(form_object.model.persisted?)

      form_object = form.build({}, { id: 1 })
      expect(form_object).to be_persisted
      expect(form_object.persisted?).to be(form_object.model.persisted?)
    end
  end

  describe '#to_model' do
    context 'with a new model' do
      it 'returns model object without key set' do
        model = form.build(email: 'jane@doe').to_model

        expect(model.id).to be(nil)
        expect(model.model_name).to eql('User')
        expect(model.to_key).to eql([])
        expect(model.to_param).to be(nil)
        expect(model).not_to be_persisted
      end
    end

    context 'with a persisted model' do
      it 'returns model object with key set' do
        model = form.build({ email: 'jane@doe' }, { id: 312 }).to_model

        expect(model.id).to be(312)
        expect(model.model_name).to eql('User')
        expect(model.to_key).to eql([312])
        expect(model.to_param).to eql('312')
        expect(model).to be_persisted
      end
    end
  end

  describe '#save' do
    it 'commits the form without extra args' do
      result = form.build({}).save.result
      expect(result).to eql('it works []')
    end

    it 'commits the form with extra args' do
      result = form.build({}).save(1, 2, 3).result
      expect(result).to eql('it works [1, 2, 3]')
    end
  end

  describe "#errors" do
    context "with a new model" do
      it "exposes an activemodel compatible error"  do
        errors = form.build({}).errors

        expect(errors).to respond_to(:[])
        expect(errors).to respond_to(:empty?)
        expect(errors).to respond_to(:blank?)

        expect(errors[:email]).to eq []
      end
    end

    it "recovers from database errors" do
      form = Class.new(ROM::Model::Form) do
        commands users: :create
        input do
          set_model_name 'User'

          attribute :email, String
        end

        def commit!(*args)

          users.try {
            raise ROM::SQL::ConstraintError.new(RuntimeError.new("duplicate key"))
          }

        end
      end

      result = form.build(email: 'test@example.com').save

      expect(result).not_to be_success

      expect(result.errors[:email]).to eq []
      expect(result.errors[:base]).to eq ["a database error prevented saving this form"]
    end



  end

  describe "#attributes" do
    it "returns processed attributes" do
      form = Class.new(ROM::Model::Form) do
        def self.name
          'UserForm'
        end

        key :foo_id, :bar_id

        input do
          set_model_name 'User'

          attribute :uid, Integer
        end
      end

      form_object = form.build(uid: "12345")
      expect(form_object.attributes[:uid]).to eq 12_345
    end
  end

  describe "#validate!" do
    it "runs validations and assigns errors" do
      form_object = form.build({})
      form_object.validate!

      expect(form_object.errors[:email]).to include "can't be blank"
    end

    it "uses processed parameters" do
      form = Class.new(ROM::Model::Form) do
        def self.name
          'UserForm'
        end

        key :foo_id, :bar_id

        input do
          set_model_name 'User'

          attribute :email, String
          attribute :country, String, default: "Unkown"
        end

        validations do
          validates :email, presence: true
          validates :country, presence: true
        end
      end

      form_object = form.build(uid: "12345")
      form_object.validate!

      expect(form_object.errors[:country]).to be_blank
    end
  end

  describe 'inheritance' do
    let(:child_form) do
      Class.new(form) do
        def self.name
          "NewUserForm"
        end
      end
    end

    it 'copies model_name' do
      expect(child_form.model_name.name).to eql(form.model_name.name)
    end

    it 'copies input' do
      expect(child_form.attributes.attribute_set[:email]).to_not be(nil)
      expect(child_form.attributes).to_not be(form.attributes)
    end

    it 'expands input' do
      child_form = Class.new(form) do
        def self.name
          "NewUserForm"
        end

        input do
          attribute :login, String
        end
      end

      expect(child_form.attributes.attribute_set[:login]).to_not be(nil)
      expect(child_form.attributes.attribute_set[:email]).to_not be(nil)

      expect(child_form.attributes).to_not be(form.attributes)
    end

    it 'copies model' do
      expect(child_form.model.attribute_set[:email]).to_not be(nil)
      expect(child_form.model).to_not be(form.model)
    end

    it 'copies validator' do
      expect(child_form.validator.validators.first).to be_instance_of(
        ActiveModel::Validations::PresenceValidator
      )
      expect(child_form.validator).to_not be(form.validator)
    end

    it "expands existing validators" do
      child_form = Class.new(form) do
        def self.name
          "NewUserForm"
        end

        input do
          attribute :login, String
        end

        validations do
          validates :login, length: { minimum: 4 }
        end
      end

      expect(child_form.validator.validators.first).to be_instance_of(
        ActiveModel::Validations::PresenceValidator
      )

      expect(child_form.validator.validators.last).to be_instance_of(
        ActiveModel::Validations::LengthValidator
      )

      expect(child_form.validator).to_not be(form.validator)
    end


  end
end
