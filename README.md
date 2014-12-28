[gem]: https://rubygems.org/gems/rom-rails
[travis]: https://travis-ci.org/rom-rb/rom-rails
[gemnasium]: https://gemnasium.com/rom-rb/rom-rails
[codeclimate]: https://codeclimate.com/github/rom-rb/rom-rails
[coveralls]: https://coveralls.io/r/rom-rb/rom-rails
[inchpages]: http://inch-ci.org/github/rom-rb/rom-rails

# rom-rails

[![Gem Version](https://badge.fury.io/rb/rom-rails.svg)][gem]
[![Build Status](https://travis-ci.org/rom-rb/rom-rails.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/rom-rb/rom-rails.png)][gemnasium]
[![Code Climate](https://codeclimate.com/github/rom-rb/rom-rails/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/rom-rb/rom-rails/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/rom-rb/rom-rails.svg?branch=master)][inchpages]

Rails integration for [Ruby Object Mapper](https://github.com/rom-rb/rom).

## Installation and setup

In your Gemfile:

```
gem 'rom'
gem 'rom-rails'
```

## Schema

Defining schema is only required for adapters that don't support inferring schema
automatically. This means if you're using `rom-sql` you don't have to define the schema.
In other cases the railtie expects the schema to be in `db/rom/schema.rb` which
is loaded before relations and mappers.

## Relations and mappers

The railtie automatically loads relations and mappers from `app/relations` and
`app/mappers` and finalizes the environment afterwards. During the booting process
rom's setup object is available via `Rails.application.config.rom.setup`.

## Relations in controllers

The recommended way of using relations in controllers is to specify which relations
are needed for particular actions using a DSL provided by the railtie:

``` ruby
class UsersController < ApplicationController
  relation 'users.index', only: :index
  relation 'users.by_name', only: :search, requires: :name

  def index
    render
  end

  def search
    render :index
  end
end
```

By doing this actions will have access to `users` which is also set as a helper
method making it available in the views.

This means **no database interaction will take place in the views or helpers**
as ROM materializes relations when "injecting" them into controller actions.

## Status

This project is still in beta state. For examples of usage please take a look
at `spec/dummy` app.

Proper documentation will be added once the interface is stable.

## Roadmap

Please refer to [issues](https://github.com/rom-rb/rom-rails/issues).

## Community

* [![Gitter chat](https://badges.gitter.im/rom-rb/chat.png)](https://gitter.im/rom-rb/chat)
* [Ruby Object Mapper](https://groups.google.com/forum/#!forum/rom-rb) mailing list

## License

See `LICENSE` file.
