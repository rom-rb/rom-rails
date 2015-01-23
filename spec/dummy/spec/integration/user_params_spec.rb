require 'spec_helper'

describe ROM::Model::Params do
  let(:params) do
    Class.new do
      include ROM::Model::Params

      param_key :test
      attribute :name, String
      validates :name, presence: true

      timestamps

      def self.name
        'Test'
      end
    end
  end

  it 'provides a way to specify timestamps with default values' do
    expect(params.new.created_at).to be_a(DateTime)
    expect(params.new.updated_at).to be_a(DateTime)
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

    it 'sets up AM name' do
      expect(params.model_name.param_key).to eql('test')
    end
  end
end
