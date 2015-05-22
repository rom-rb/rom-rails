ROM::Rails::Railtie.configure do |config|
  config.repositories[:default] = [:sql, "sqlite://#{Rails.root}/db/#{Rails.env}.sqlite3"]
  config.repositories[:test] = [:test_adapter, foo: :bar]
end
