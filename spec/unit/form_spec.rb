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

  describe 'input DSL' do
    it 'defines params handler' do
      expect(form.params.attribute_set[:email]).not_to be(nil)
      expect(form.params.model_name).to eql('User')
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
      expect(form.validator).not_to be(nil)

      expect { form.validator.call(email: 'jane@doe') }.not_to raise_error

      expect { form.validator.call(email: '') }.to raise_error(
        ROM::Model::ValidationError
      )
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
end
