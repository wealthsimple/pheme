# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "pheme/version"

Gem::Specification.new do |gem|
  gem.name          = "pheme"
  gem.version       = Pheme::VERSION
  gem.authors       = ["Peter Graham"]
  gem.email         = ["peter@wealthsimple.com"]
  gem.description   = %q{}
  gem.summary       = %q{}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-its"
  gem.add_development_dependency "rspec-collection_matchers"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "timecop"
  gem.add_development_dependency "rspec_junit_formatter", "~> 0.2"
end
