ROM::Rails::Railtie.configure do |config|
  scheme = RUBY_ENGINE == 'jruby' ? 'jdbc:sqlite' : 'sqlite'
  config.gateways[:default] = [:sql, "#{scheme}://#{Rails.root}/db/#{Rails.env}.sqlite3"]
  config.gateways[:test] = [:test_adapter, foo: :bar]
end
