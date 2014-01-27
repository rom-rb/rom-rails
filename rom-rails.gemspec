# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rom/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "rom-rails"
  spec.version       = Rom::Rails::VERSION
  spec.authors       = ["Piotr Solnica"]
  spec.email         = ["piotr.solnica@gmail.com"]
  spec.summary       = %q{Integrate Ruby Object Mapper with Rails}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'railties', ['>= 3.0', '< 5.0']

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
