require 'spec_helper'

describe 'Embedded validators' do
  it 'allows defining a validator for a nested hash' do
    user_validator = Class.new do
      include ROM::Model::Validator

      set_model_name 'User'

      validates :name, presence: true

      embedded :address do
        set_model_name 'Address'

        validates :street, :city, :zipcode, presence: true
      end
    end

    attributes = { name: '', address: { street: '', city: '', zipcode: '' } }

    expect { user_validator.call(attributes) }.to raise_error(
      ROM::Model::ValidationError)

    validator = user_validator.new(attributes)

    expect(validator).to_not be_valid

    expect(validator.errors[:name]).to include("can't be blank")

    expect(validator.errors[:address]).to_not be_empty

    address_errors = validator.errors[:address].first

    expect(address_errors[:street]).to include("can't be blank")
    expect(address_errors[:city]).to include("can't be blank")
    expect(address_errors[:zipcode]).to include("can't be blank")
  end
end
