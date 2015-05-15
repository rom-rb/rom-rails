ROM::Rails::Railtie.configure do |config|
  db_config = ROM::Rails::ActiveRecord::Configuration.build(
    Rails.application.config.database_configuration[Rails.env].symbolize_keys
    .merge(root: Rails.root)
  )

  config.repositories[:default] = [:sql, db_config[:uri], db_config[:options]]

  config.repositories[:test] = [:test_adapter, foo: :bar]
end
