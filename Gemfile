source 'https://rubygems.org'

gemspec

RAILS_VERSION = '4.2.1'

%w(railties actionview actionpack activerecord).each do |name|
  gem name, RAILS_VERSION
end

gem 'rom-model', github: 'rom-rb/rom-model', branch: 'master'

gem 'sqlite3', platforms: [:mri, :rbx]
gem 'byebug', platforms: :mri

platforms :jruby do
  gem 'jdbc-sqlite3'
end

group :test do
  gem 'rack-test'
  gem 'rom', github: 'rom-rb/rom', branch: 'master'
  gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
  gem 'rspec-rails', '~> 3.1'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'capybara'
  gem 'generator_spec'
end
