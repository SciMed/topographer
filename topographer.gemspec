# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'Topographer/version'

Gem::Specification.new do |spec|
  spec.name          = 'topographer'
  spec.version       = Topographer::VERSION
  spec.authors       = ['Mike Simpson', 'Emerson Huitt']
  spec.email         = ['mjs2600@gmail.com', 'ehuitt@gmail.com']
  spec.description   = %q{Topographer enables importing of models from various input sources.}
  spec.summary       = %q{Topographer allows the mapping of columnar input data to fields for active record models. This facilitates importing from a variety of sources.}
  spec.homepage      = ""
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency('activesupport', ['>= 3'])

  spec.add_development_dependency('bundler', ['~> 1.3'])
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
end
