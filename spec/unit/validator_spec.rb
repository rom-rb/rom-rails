require 'spec_helper'

describe ROM::Model::Validator do
  subject(:validator) do
    Class.new do
      include ROM::Model::Validator

      validates :name, presence: true

      def self.name
        'Test'
      end
    end
  end

  describe '.call' do
    it 'returns params when valid' do
      expect(validator.call(name: 'Jane')).to eql(name: 'Jane')
    end

    it 'raises error when invalid' do
      expect { validator.call(name: nil) }.to raise_error(
        ROM::Model::ValidationError
      )
    end
  end
end
