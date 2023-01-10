source 'https://rubygems.org'

gemspec

RAILS_VERSION = ENV.fetch("RAILS_VERSION", '7.0.4').freeze

%w(railties actionview actionpack activerecord).each do |name|
  gem name, "~> #{RAILS_VERSION}"
end

gem 'byebug', platforms: :mri
gem 'sqlite3', platforms: [:mri, :rbx]



if ENV["USE_ROM_MASTER"].eql?("true")
  gem 'rom', git: 'https://github.com/rom-rb/rom', branch: 'master' do
    gem 'rom-core'
    gem 'rom-mapper'
    gem 'rom-repository', group: :tools
  end

  gem 'rom-sql', github: 'rom-rb/rom-sql', branch: 'master'
else
  gem "rom"
  gem "rom-sql"

  gem "sequel", "5.31.0"
end

platforms :jruby do
  gem 'jdbc-sqlite3'
end

group :test do
  gem 'debug'
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner', "~> 1.8.1"
  gem 'generator_spec'
  gem 'rack-test'
  gem 'rspec-rails', '~> 3.1'
end
