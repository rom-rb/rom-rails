ROM::Rails::Railtie.configure do |config|
  scheme = RUBY_ENGINE == 'jruby' ? 'jdbc:sqlite' : 'sqlite'
  config.repositories[:default] = [:sql, "#{scheme}://#{Rails.root}/db/#{Rails.env}.sqlite3"]
  config.repositories[:test] = [:test_adapter, foo: :bar]
end
