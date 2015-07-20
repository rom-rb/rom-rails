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

Rails integration for [Ruby Object Mapper](https://github.com/rom-rb/rom) which
ships with:

* Params sanitizer/coercer extension
* Validation extension based on `ActiveModel`
* Relation generators
* Mapper generators
* Command generators

## Tests

To run tests:

    RAILS_ENV=test bundle exec rake db:migrate
    bundle exec rake

## Issues

Please report any issues in the main [rom-rb/rom](https://github.com/rom-rb/rom/issues) issue tracker.

## Resources

You can read more about ROM and Rails on the official website:

* [Introduction to ROM](http://rom-rb.org/introduction/)
* [Rails tutorial](http://rom-rb.org/tutorials/todo-app-with-rails/)


## Community

* [![Gitter chat](https://badges.gitter.im/rom-rb/chat.png)](https://gitter.im/rom-rb/chat)
* [Ruby Object Mapper](https://groups.google.com/forum/#!forum/rom-rb) mailing list

## License

See `LICENSE` file.
