require 'spec_helper'

describe ROM::Model::Params do
  let(:params) do
    Class.new do
      include ROM::Model::Params

      attribute :name, String

      timestamps
    end
  end

  it 'provides a way to specify timestamps with default values' do
    expect(params.new.created_at).to be_a(DateTime)
    expect(params.new.updated_at).to be_a(DateTime)
  end
end
