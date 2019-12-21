---
position: 3
chapter: Rails
title: Setup
---

Rails integration is provided by [rom-rails](https://github.com/rom-rb/rom-rails) project. Simply add it to your Gemfile:

``` ruby
gem 'rom-rails'
```

## Configuring Railtie

Create a rom initializer:

``` ruby
# config/initializers/rom.rb
ROM::Rails::Railtie.configure do |config|
  config.gateways[:default] = [:sql, ENV.fetch('DATABASE_URL')]
end
```

You can provide additional adapter-specific options, for example you can enable specific sql plugins for postgres:

``` ruby
# config/initializers/rom.rb
ROM::Rails::Railtie.configure do |config|
  config.gateways[:default] = [:sql,
    ENV.fetch('DATABASE_URL'), extensions: [:pg_hstore]
  ]
end
```

You can also provide a list of relations that should not be inferred from your schema automatically:

``` ruby
# config/initializers/rom.rb
ROM::Rails::Railtie.configure do |config|
  config.gateways[:default] = [:sql,
    ENV.fetch('DATABASE_URL'), not_inferrable_relations: [:schema_migrations]
  ]
end
```

## Migration Tasks

The railtie provides rake tasks for managing your database schema. You need to enable them in your `Rakefile`:

``` ruby
require 'rom/sql/rake_task'
```

After that, you have access to following tasks:

* `rake db:create_migration[migration_name]` - creates a new migration file
* `rake db:migrate` - runs pending migrations
* `rake db:clean` - cleans the database
* `rake db:reset` - drops tables and re-runs migrations

## Accessing Container

In Rails environment ROM container is accessible via `ROM.env`:

``` ruby
ROM.env # returns the container
```

In your controllers you can access ROM container by `rom` variable:

``` ruby
class UsersController < ApplicationController
  def show
    @user = rom.relation(:users).by_id(params[:id]).one
  end
end
```

^WARNING
Accessing the global container directly is considered as a bad practice. The recommended way is to use a DI mechanism to inject specific ROM components as dependencies into your objects.

For example you can use [dry-container](https://github.com/dryrb/dry-container) and [dry-auto_inject](https://github.com/dryrb/dry-auto_inject) to define your own application container and specify dependencies there to have them automatically injected.

See [rom-rails-skeleton](https://github.com/solnic/rom-rails-skeleton) for an example of such setup.
^

## Defining Relations

Relation class definitions are automatically loaded from `app/relations`. The following code defines a `users` relation for the `:sql` adapter:

``` ruby
class Users < ROM::Relation[:sql]
  # some methods
end

# access registered relation via container
ROM.env.relations[:users]
```

## Defining Commands

Command class definitions are automatically loaded from `app/commands`. The following code defines a command which inserts data into `users` relation:

``` ruby
# app/commands/create_user.rb
class CreateUser < ROM::Commands::Create[:sql]
  relation :users
  register_as :create
  result :one
end

# access registered relation via container
ROM.env.commands[:users][:create]
```

## Defining Custom Mappers

If you want to use custom mappers you can place them under `app/mappers`:

``` ruby
# app/mappers/user_mapper.rb
class UserMapper < ROM::Mapper
  relation :users

  # some mapping logic
end
```

## Running alongside ActiveRecord

There might be some cases where you will want to run ROM alongside ActiveRecord. Since ROM is designed to work independently, you will need to take few additional steps. ROM creates its own connections and Rails above version 5 won't allow you to drop the database since there are active connections on it.

``` ruby
# lib/tasks/db.rake
task :remove_rom_connection => [:environment] do
  ROM.env && ROM.env.disconnect
end

Rake::Task["db:drop"].clear_prerequisites()
Rake::Task["db:drop"].enhance [:remove_rom_connection, :load_config, :check_protected_environments]

Rake::Task["db:reset"].clear_prerequisites()
Rake::Task["db:reset"].enhance [:remove_rom_connection, "db:drop", "db:setup"]
```

Since migrations (and other) tasks require environment, ROM will be loaded and will throw an exception, because relations will try to load tables before migrations have actually run. We know this is an ugly solution, but we are working hard to solve this case. This monkey patch will give you reasonable information to act upon if the necessity arises.

``` ruby
# config/initializers/rom_monkey.rb
module ROM
  module Rails
    class Railtie < ::Rails::Railtie
      alias_method :create_container!, :create_container
      def create_container
        begin
          create_container!
        rescue => e
          puts "Container failed to initialize because of #{e.inspect}"
          puts "This message comes from the monkey patch in #{__FILE__}, if you are using rake, then this is fine"
        end
      end
    end
  end
end
```
