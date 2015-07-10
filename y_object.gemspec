# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'y_object/version'

Gem::Specification.new do |spec|
  spec.name          = "y_object"
  spec.version       = YObject::VERSION
  spec.authors       = ["Roman Kalnytsky"]
  spec.email         = ["moranibaca@gmail.com"]
  spec.summary       = %q{Allow to act with YAML or hash based data as with objects}
  spec.description   = %q{Transform YAML or Hash based data to YObject class that is very similar to Hash but add some object cookies}
  spec.homepage      = "https://github.com/imdrasil/y_object"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
end
