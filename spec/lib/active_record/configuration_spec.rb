require 'rom/rails/active_record/configuration'
require 'active_record'
require 'active_record/database_configurations' if Rails::VERSION::MAJOR >= 6

RSpec.describe ROM::Rails::ActiveRecord::Configuration do
  let(:root) { Pathname.new('/path/to/app') }

  subject(:configuration) { described_class.new(root: root) }

  def uri_for(config)
    result = read(config)
    result.is_a?(Hash) ? result[:uri] : result
  end

  def read(config)
    configuration.build(config)
  end

  def parse(uri)
    URI.parse(uri.gsub(/^jdbc:/, ''))
  end

  it 'raises an error without specifying a database'

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
      expect(uri.starts_with?('jdbc:')).to be(RUBY_ENGINE == 'jruby')
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
      expect(uri.starts_with?('jdbc:')).to be(RUBY_ENGINE == 'jruby')
    end

    it 'expands the path' do
      uri = uri_for(adapter: 'sqlite3', database: database)
      expect(parse(uri).path).to eql(root.join(database).to_s)
    end
  end

  describe '#build' do
    context 'with an ActiveRecord mysql2 configuration' do
      it 'returns the database uri and options' do
        config = {
          pool: 5,
          adapter: 'mysql2',
          username: 'root',
          password: 'password',
          database: 'database',
          host: 'example.com'
        }

        expected_uri = 'mysql2://root:password@example.com/database'
        expected_uri = "jdbc:#{expected_uri}" if RUBY_ENGINE == 'jruby'

        expect(read(config)).to eq uri: expected_uri, options: { pool: 5 }
      end

      it 'handles special characters in username and password' do
        config = {
          pool: 5,
          adapter: 'mysql2',
          username: 'r@o%ot',
          password: 'p@ssw0rd#',
          database: 'database',
          host: 'example.com'
        }

        expected_uri = 'mysql2://r%40o%25ot:p%40ssw0rd%23@example.com/database'
        expected_uri = "jdbc:#{expected_uri}" if RUBY_ENGINE == 'jruby'

        expect(read(config)).to eq uri: expected_uri, options: { pool: 5 }
      end
    end
  end

  if Rails::VERSION::MAJOR >= 6
    context "with an activerecord 6 configuration" do
      subject(:configuration) { described_class.new(root: root, configurations: railsconfig, env: "test") }
      let(:railsconfig) { ActiveRecord::DatabaseConfigurations.new(config_file) }

      context "with only a single database" do
        let(:config_file) {
          {
            test: {
              adapter: 'mysql',
              host: 'example.com',
              database: 'test',
              username: 'user',
              encoding: 'utf8'
            }
          }
        }

        it "returns the default hash" do
          expected_uri = uri_for(config_file[:test])
          expect(configuration.call[:default]).to match(uri: expected_uri, options: { encoding: 'utf8' })
        end
      end

      context "with multiple configured databases" do
        let(:config_file) {
          {
            test: {
              reader: {
                adapter: 'mysql',
                host: 'example.com',
                database: 'test_reader',
                username: 'user',
                encoding: 'utf8'
              },
              writer: {
                adapter: 'mysql',
                host: 'write.example.com',
                database: 'test_writer',
                username: 'user',
                encoding: 'utf8'
              }
            }
          }
        }

        it "configures the first database as the default" do
          expected_uri = uri_for(config_file[:test][:reader])
          expect(configuration.call[:default]).to match(uri: expected_uri, options: {encoding: 'utf8'})
        end
      end
    end

  end
end
