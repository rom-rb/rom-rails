require 'rom-rails'

describe ROM, '.finalize' do
  subject(:env) { ROM.finalize.env }

  before { ROM.setup(:memory) }

  it 'sets up lazy-env first' do
    expect(env).to be_instance_of(ROM::LazyEnv)
  end

  it 'triggers finalization on relation access' do
    relation = Class.new(ROM::Relation[:memory]) do
      dataset :users
      register_as :users
    end

    expect(env.relation(:users).relation).to be_instance_of(relation)
  end

  it 'triggers finalization on command access' do
    Class.new(ROM::Relation[:memory]) do
      dataset :users
      register_as :users
    end

    command = Class.new(ROM::Commands::Create[:memory]) do
      relation :users
      register_as :create
    end

    expect(env.command(:users).create).to be_instance_of(command)
  end

  it 'triggers finalization on mapper access' do
    mapper = Class.new(ROM::Mapper) do
      relation :users
      register_as :entity
    end

    expect(env.mappers[:users].entity).to be_instance_of(mapper)
  end

  it 'triggers finalization on gateways access' do
    expect(env.gateways[:default]).to be_instance_of(ROM::Memory::Gateway)
  end
end
