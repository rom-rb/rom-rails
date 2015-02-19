require 'spec_helper'

describe ROM::Rails::ConfigurationBuilder::ConfigurationHashTransformer do
  before do
    allow(described_class)
      .to receive_messages(
        root: '/path/to/app'
      )
  end

  let(:config) do
    { 'adapter' => 'sqlite3', 'database' => 'db/development.sqlite3' }
  end

  it 'builds a configuration' do
    expect(described_class.transform(config))
      .to eq([:sql, 'sqlite:///path/to/app/db/development.sqlite3', {}])
  end

  def uri_for(config)
    result = read(config)
    result.is_a?(Array) ? result[1] : result
  end

  def read(config)
    described_class.transform(config)
  end

  def parse(uri)
    URI.parse(uri.gsub(/^jdbc:/, ''))
  end

  context 'with postgresql adapter' do
    it 'rewrites the scheme' do
      uri = uri_for(adapter: 'postgresql', database: 'test')
      expect(parse(uri).scheme).to eql('postgres')
    end

    it 'does not use jdbc even on jruby' do
      uri = uri_for(adapter: 'postgresql', database: 'test')
      expect(uri).to_not start_with('jdbc:')
    end

    it 'only includes username if no password is given' do
      uri = uri_for(
        adapter: 'postgresql',
        host: 'example.com',
        database: 'test',
        username: 'user'
      )

      expect(parse(uri).userinfo).to eql('user')
    end

    it 'includes username and password if both are given' do
      uri = uri_for(
        adapter: 'postgresql',
        database: 'test',
        username: 'user',
        password: 'password',
        host: 'example.com'
      )

      expect(parse(uri).userinfo).to eql('user:password')
    end

    it 'omits userinfo if neither username nor password are given' do
      uri = uri_for(adapter: 'postgresql', database: 'test')
      expect(parse(uri).userinfo).to be_nil
    end

    it 'properly handles configuration without a host' do
      uri = uri_for(adapter: 'postgresql', database: 'test')
      expect(uri).to eql('postgres:///test')
    end
  end

  context 'with mysql adapter' do
    it 'sets default password to an empty string' do
      uri = uri_for(adapter: 'mysql', database: 'test', username: 'root', host: 'example.com')
      expect(parse(uri).userinfo).to eql('root:')
    end

    it 'uses jdbc only on jruby' do
      uri = uri_for(adapter: 'mysql', database: 'test')
      expect(uri.start_with?('jdbc:')).to be(RUBY_ENGINE == 'jruby')
    end
  end

  context 'with sqlite3 adapter' do
    let(:database) { Pathname.new('db/development.sqlite3') }
    let(:config) { { adapter: adapter, database: database } }

    it 'rewrites the scheme' do
      uri = uri_for(adapter: 'sqlite3', database: database)
      expect(parse(uri).scheme).to eql('sqlite')
    end

    it 'uses jdbc only on jruby' do
      uri = uri_for(adapter: 'sqlite3', database: database)
      expect(uri.start_with?('jdbc:')).to be(RUBY_ENGINE == 'jruby')
    end

    it 'expands the path' do
      uri = uri_for(adapter: 'sqlite3', database: database)
      expect(parse(uri).path).to eql(Pathname.new("/path/to/app").join(database).to_s)
    end
  end
end

describe ROM::Rails::ConfigurationBuilder do
  def switch_buildables(state, builders)
    builders.each do |sym|
      c = "ROM::Rails::ConfigurationBuilder::#{sym.to_s.camelize}Builder".constantize
      allow(c).to receive_messages(:buildable? => state)
    end
  end

  def enable_builders(*builders)
    switch_buildables(true, builders)
  end

  def disable_builders(*builders)
    switch_buildables(false, builders)
  end

  context 'buildable via config file' do
    before do
      enable_builders(:config_file, :active_record, :data_mapper, :environment)
    end

    it 'selects ConfigFileBuilder' do
      expect(ROM::Rails::ConfigurationBuilder::ConfigFileBuilder).to receive(:build)
      described_class.build
    end
  end

  context 'buildable via ActiveRecord' do
    before do
      enable_builders(:active_record, :data_mapper, :environment)
      disable_builders(:config_file)
    end

    it 'selects ActiveRecordBuilder' do
      expect(ROM::Rails::ConfigurationBuilder::ActiveRecordBuilder).to receive(:build)
      described_class.build
    end
  end

  context 'buildable via DataMapper' do
    before do
      enable_builders(:data_mapper, :environment)
      disable_builders(:config_file, :active_record)
    end

    it 'selects DataMapperBuilder' do
      expect(ROM::Rails::ConfigurationBuilder::DataMapperBuilder).to receive(:build)
      described_class.build
    end
  end

  context 'buildable via environment variable' do
    before do
      enable_builders(:environment)
      disable_builders(:config_file, :active_record)
    end

    it 'selects EnvironmentBuilder' do
      expect(ROM::Rails::ConfigurationBuilder::EnvironmentBuilder).to receive(:build)
      described_class.build
    end
  end
end
