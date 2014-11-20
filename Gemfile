source 'https://rubygems.org'

gemspec

gem 'rails', '4.1.7'

gem 'sqlite3', platforms: [:mri, :rbx]
gem 'jdbc-sqlite3', platforms: :jruby

group :test do
  gem 'rspec-rails', '~> 3.1'

  gem 'database_cleaner'

  gem 'rom', git: 'https://github.com/rom-rb/rom.git', branch: 'master'
  gem 'rom-sql', git: 'https://github.com/rom-rb/rom-sql.git', branch: 'master'
end
