# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

if RUBY_ENGINE == 'rbx'
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require Pathname(__FILE__).dirname.join("dummy/config/environment")

require 'rspec/rails'
require 'database_cleaner'
require 'capybara/rails'
require 'generator_spec'

begin
  require 'byebug'
rescue LoadError
end

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

Dry::Core::Deprecations.set_logger!(Rails.root.join('log/deprecations.log'))

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = "tmp/examples.txt"

  config.before(:suite) do
    conn = rom.gateways[:default].connection

    DatabaseCleaner[:sequel, connection: conn].strategy = :transaction
    DatabaseCleaner[:sequel, connection: conn].clean_with(:truncation)
  end

  config.around(:each) do |example|
    conn = rom.gateways[:default].connection

    DatabaseCleaner[:sequel, connection: conn].cleaning { example.run }
  end
end

def rom
  ROM.env
end
