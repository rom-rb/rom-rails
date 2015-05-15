# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rom/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "rom-rails"
  spec.version       = ROM::Rails::VERSION.dup
  spec.authors       = ["Piotr Solnica"]
  spec.email         = ["piotr.solnica@gmail.com"]
  spec.summary       = 'Integrate Ruby Object Mapper with Rails'
  spec.homepage      = "http://rom-rb.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'rom', '~> 0.7', '>= 0.7.0'
  spec.add_runtime_dependency 'addressable', '~> 2.3'
  spec.add_runtime_dependency 'charlatan', '~> 0.1'
  spec.add_runtime_dependency 'virtus', '~> 1.0', '>= 1.0.5'
  spec.add_runtime_dependency 'railties', ['>= 3.0', '< 5.0']

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop", "~> 0.28.0"
end
