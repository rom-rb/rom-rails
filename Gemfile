source 'https://rubygems.org'

gemspec

gem 'rails', '4.2.0'

gem 'sqlite3', platforms: [:mri, :rbx]
gem 'jdbc-sqlite3', platforms: :jruby

group :test do
  gem 'rom', github: 'rom-rb/rom', branch: 'master'
  gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
  gem 'rspec-rails', '~> 3.1'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'capybara'
  gem 'generator_spec'
end
