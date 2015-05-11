require 'spec_helper'

describe 'ROM initializer' do
  it 'allows setting up a custom repository' do
    repository = ROM::TestAdapter::Repository.new(foo: :bar)
    relation = DummyRelation.new([])

    expect(rom.repositories[:test]).to eql(repository)
    expect(rom.relations.dummy).to eql(relation)
  end
end
