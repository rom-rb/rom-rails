ROM::Rails::Railtie.configure do |config|
  config.repositories[:test] = [:test_adapter, foo: :bar]
end
