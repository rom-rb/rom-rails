RSpec.describe 'ROM initializer' do
  it 'allows setting up a custom gateway' do
    gateway = ROM::TestAdapter::Gateway.new(foo: :bar)
    relation = DummyRelation.new([])

    expect(rom.gateways[:default]).to eql(gateway)
    expect(rom.relations.dummy).to eql(relation)
  end

  it 'loads commands from additionall auto_registration_paths' do
    expect(rom.commands.tasks.create_additional).to be_a(CreateAdditionalTask)
  end
end
