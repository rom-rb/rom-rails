RSpec.describe 'ROM initializer' do
  it 'allows setting up a custom gateway' do
    gateway = ROM::TestAdapter::Gateway.new(foo: :bar)
    relation = DummyRelation.new([])

    expect(rom.gateways[:default]).to eql(gateway)
    expect(rom.relations.dummy).to eql(relation)
  end

  it 'loads commands from additional auto_registration_paths' do
    expect(rom.commands.tasks.create_additional).to be_a(CreateAdditionalTask)
  end

  it 'allows namespace configuration on autoload paths' do
    puts rom.commands.tasks.elements
    expect(rom.commands.tasks.namespaced_additional).to be_a(NamespacedApp::Persistence::Commands::CreateAdditionalTask)
  end
end
