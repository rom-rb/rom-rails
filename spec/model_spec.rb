require 'spec_helper'

describe ROM::Model::Params do
  let(:klass) {
    Class.new do
      include ROM::Model::Params

      attribute :name, String
    end
  }

  it 'fails loudly when given an incorrect type' do
    expect {
      klass.new(name: [])
    }.to raise_error(Virtus::CoercionError)
  end

  it 'does not fail on nil or missing attributes' do
    expect {
      klass.new
    }.not_to raise_error
  end
end
