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
      input = {
        'name' =>'Jane',
        'hash' => { 'one' => '', 'two' => 2 },
        'array' => [{ 'three' => '', 'four' => 4 }, 5]
      }

      form_object = form.build(input)

      expect(form_object.params).to eql(
        name: 'Jane', hash: { two: 2 }, array: [{ four: 4 }, 5]
      )
    end
  end

  describe '.key' do
    it 'returns default key' do
      expect(form.key).to eql([:id])
      expect(form.new({}, id: 312).to_key).to eql([312])
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
      expect(form.new({}, foo_id: 312, bar_id: 132).to_key).to eql([312, 132])
    end
  end

  describe '.model_name' do
    it 'delegates to Params.model_name' do
      expect(form.model_name).to be(form.params.model_name)
    end
  end

  describe 'input DSL' do
    it 'defines params handler' do
      expect(form.const_defined?(:Params)).to be(true)
      expect(form.params.attribute_set.map(&:name)).to eql([:email])
      expect(form.params.model_name).to eql('User')
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

      form_object = form.build({}, id: 1)
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

        expect(errors).to be_instance_of(
          ActiveModel::Errors
        )

        expect(errors[:email]).to eq []
      end
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
      expect(child_form.params.attribute_set[:email]).to_not be(nil)
      expect(child_form.params).to_not be(form.params)
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
  end
end
