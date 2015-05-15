## v0.3.2 to-be-released

### Fixed

* Generator uses correct directory for commands (cflipse)

[Compare v0.3.1...HEAD](https://github.com/rom-rb/rom-rails/compare/v0.3.1...HEAD)

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
