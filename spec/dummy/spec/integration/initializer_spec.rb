require 'spec_helper'

describe 'ROM initializer' do
  it 'allows setting up a custom gateway' do
    gateway = ROM::TestAdapter::Gateway.new(foo: :bar)
    relation = DummyRelation.new([])

    expect(rom.gateways[:test]).to eql(gateway)
    expect(rom.relations.dummy).to eql(relation)
  end
end
