ROM::Rails::Railtie.configure do |config|
  scheme = RUBY_ENGINE == 'jruby' ? 'jdbc:sqlite' : 'sqlite'
  config.gateways[:arro] = [:test_adapter, uri: 'http://example.org' ]
  config.gateways[:sql] = [:sql, "#{scheme}://#{Rails.root}/db/#{Rails.env}.sqlite3"]
  config.gateways[:default] = [:test_adapter, foo: :bar]
  config.auto_registration_paths += [Rails.root.join('lib', 'additional_app', 'persistence')]
end
