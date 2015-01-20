require 'spec_helper'

describe 'Form' do
  describe 'input and validator DSL' do
    it 'defines params handler and validator' do
      form = Class.new(ROM::Model::Form) do
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
      end

      expect(form.params.attribute_set[:email]).not_to be(nil)
      expect(form.params.model_name).to eql('User')
      expect(form.validator).not_to be(nil)

      expect { form.validator.call(email: 'jane@doe') }.not_to raise_error

      expect { form.validator.call(email: '') }.to raise_error(
        ROM::Model::ValidationError
      )
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
end
