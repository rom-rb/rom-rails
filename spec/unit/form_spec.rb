require 'spec_helper'

describe 'Form' do
  describe 'input DSL' do
    it 'defines params handler' do
      form = Class.new(ROM::Model::Form) do
        input do
          param_key :user
          attribute :email, String
        end
      end

      expect(form.params.attribute_set[:email]).not_to be(nil)
      expect(form.params.model_name.name).to eql('user')
    end

    it 'raises error when attribute is in conflict with form interface' do
      expect {
        Class.new(ROM::Model::Form) do
          input do
            param_key :user
            attribute :commit!
          end
        end
      }.to raise_error(ArgumentError, /commit! attribute is in conflict/)
    end
  end
end
