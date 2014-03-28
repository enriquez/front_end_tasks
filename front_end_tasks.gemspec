# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'front_end_tasks/version'

Gem::Specification.new do |spec|
  spec.name          = "front_end_tasks"
  spec.version       = FrontEndTasks::VERSION
  spec.authors       = ["Mike Enriquez"]
  spec.email         = ["mike@enriquez.me"]
  spec.description   = %q{Command line tool for client side web application development}
  spec.summary       = %q{Front End Tasks comes with everything you need to minify javascript, minify css, run tests, run lint, and run a development server.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "nokogiri", "~> 1.6.1"
  spec.add_dependency "uglifier", "~> 2.5.0"
  spec.add_dependency "yui-compressor", "~> 0.12.0"
  spec.add_dependency "webrick", "~> 1.3.1"
  spec.add_dependency "jshintrb", "~> 0.2.4"
  spec.add_dependency "jasmine", "~> 2.0.0"
end
