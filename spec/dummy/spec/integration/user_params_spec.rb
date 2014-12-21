require 'spec_helper'

describe ROM::Model::Params do
  let(:params) do
    Class.new {
      include ROM::Model::Params
      attribute :name, String
      validates :name, presence: true

      def self.name
        'Test'
      end
    }
  end

  describe '#valid?' do
    it 'returns true when attributes are valid' do
      user_params = params.new(name: 'Jane')
      expect(user_params).to be_valid
    end

    it 'returns false when attributes are not valid' do
      user_params = params.new(name: '')
      expect(user_params).not_to be_valid
    end
  end
end
