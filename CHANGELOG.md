## v0.9.0  2017-01-30

### Added

* Add `rom-repository` generator (fmartin91)

### Changed

* Updated to work with ROM 3.0.beta (maximderbin, cflipse)
* Command generators now produce a flat directory structure (cflipse)
* Dropped runtime dependency on `virtus` (bilby91)
* Updated generators to remove validatior hints (cflipse)
* Updated generators to provide before hook hints, rather than override `execute` (cflipse)

### Internal

* [`rom-support`](https://github.com/rom-rb/rom-support) dependency was replaced with [`dry-core`](https://github.com/dry-rb/dry-core) (solnic + flash-gordon)

## v0.8.0 2016-08-08
### Changed

* Updated to work with Rails 5 (cflipse)
* Form validations are now handled entirely within form (cflipse)
* [Rails5] when applicable, parmeters are converted to unsafe hash (cflipse)

### Deprecated
* Dropping support for ruby 2.1 and below

## v0.7.0 2016-07-27

### Changed
* Updated to work with rom 2.0
* Loosen Gem dependencies for Rails 4.2
* Allow multiple auto_registration paths (vbyno)

[Compare v0.6.0...v0.7.0](https://github.com/rom-rb/rom-rails/compare/v0.6.0...v0.7.0)

### Fixed
* Fixed generated mapper's `register_as` (duduribeiro)

## v0.6.0 2016-01-06

### Changed
* Updated to work with new ROM configuration API.

[Compare v0.5.0...v0.6.0](https://github.com/rom-rb/rom-rails/compare/v0.5.0...v0.6.0)

## v0.5.0 2015-08-19

### Changed

* Raise a helpful error when trying to use uniqueness validation without a relation (xaviershay)
* Switched to extracted rom-model (solnic)
* Updated to work with ROM 0.9.0 (solnic)

### Fixed

* Setting connectin URI for jruby that needs jdbc adapter (austinthecoder)

[Compare v0.4.0...v0.5.0](https://github.com/rom-rb/rom-rails/compare/v0.4.0...v0.5.0)

## v0.4.0 2015-06-22

### Added

* `embedded` validators allowing to nest validations for embedded values (solnic)
* Uniqueness validation supports `:scope` option (vrish88)

### Changed

* `ROM.env` is lazy-finalized on first access of any of the components (solnic)
* `db:setup` provided by the railtie now loads `:environment` (solnic)
* `repositories` in railtie configuration deprecated in favor of `gateways` (solnic)

### Fixed

* `method_missing` in validators behaves properly now (solnic)

[Compare v0.3.3...v0.4.0](https://github.com/rom-rb/rom-rails/compare/v0.3.3...v0.4.0)

## v0.3.3 2015-05-22

### Added

* `db:setup` task which works OOTB with rom-sql tasks (solnic)

### Changed

* `MissingRepositoryConfigError` is raised when repositories are not configured (solnic)

### Fixed

* The railitie no longer set `nil` as default repository when ActiveRecord is not present (solnic)

[Compare v0.3.2...v0.3.3](https://github.com/rom-rb/rom-rails/compare/v0.3.2...v0.3.3)

## v0.3.2 2015-05-17

### Fixed

* Generator uses correct directory for commands (cflipse)
* Generators can now add `register_as` and `repository` settings (cflipse)
* Database errors are now wrapped in Form objects so they can be handled gracefully (cflipse)

[Compare v0.3.1...v0.3.2](https://github.com/rom-rb/rom-rails/compare/v0.3.1...v0.3.2)

## v0.3.1 2015-04-04

### Added

* `Form.mappings` which sets up auto-mapping command results (solnic)
* Form descendants can use `input` and `validations` blocks (cflipse)
* Form generators can generate a shared base form class for new/update forms (cflipse)

[Compare v0.3.0...v0.3.1](https://github.com/rom-rb/rom-rails/compare/v0.3.0...v0.3.1)

## v0.3.0 2015-03-22

### Added

* `ROM::Model::Form` for modeling and setting up web-forms (solnic + cflipse)
* Support for timestamps attributes in Form objects (kchien)
* Allow setup using a configuration block from railtie (aflatter)

### Changed

* [BREAKING] Model::Params renamed to Model::Attributes (solnic + cflipse)
* Improved initialization process which works with AR-style configurations (aflatter)

[Compare v0.2.1...v0.3.0](https://github.com/rom-rb/rom-rails/compare/v0.2.1...v0.3.0)

## v0.2.1 2015-01-07

### Changed

* input params uses virtus' `:strict` mode by default (stevehodgkiss)

### Fixed

* `rom` extension is now mixed into ActionController::Base which addresses #12 (solnic)

[Compare v0.2.1...v0.2.0](https://github.com/rom-rb/rom-rails/compare/v0.2.0...v0.2.1)

## v0.2.0 2014-12-31

### Added

* Generators for relations, mappers and commands (solnic)
* Support for Spring and reload in development mode (solnic)

### Fixed

* Setup will be skipped when there are missing elements in the registries (solnic)

[Compare v0.1.0...v0.2.0](https://github.com/rom-rb/rom-rails/compare/v0.1.0...v0.2.0)

## v0.1.0 2014-12-06

### Added

* Support for loading commands (solnic)

[Compare v0.0.2...v0.1.0](https://github.com/rom-rb/rom-rails/compare/v0.0.2...v0.1.0)

## v0.0.2 2014-11-25

### Added

* Support for username and password in database.yml (solnic)
* Support for more db schemes (solnic)
* Missing runtime dep on rom gem (solnic)

[Compare v0.0.1...v0.0.2](https://github.com/rom-rb/rom-rails/compare/v0.0.1...v0.0.2)

## v0.0.1 2014-11-24

First public release
