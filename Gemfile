source 'https://rubygems.org'

gemspec

gem 'rails', '4.2.0'

gem 'sqlite3', platforms: [:mri, :rbx]

platforms :jruby do
  gem 'jdbc-sqlite3'
  gem 'activerecord-jdbc-adapter'
end

group :test do
  gem 'rom', github: 'rom-rb/rom', branch: 'master'
  gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
  gem 'byebug', platforms: :mri
  gem 'rspec-rails', '~> 3.1'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'capybara'
  gem 'generator_spec'
end
