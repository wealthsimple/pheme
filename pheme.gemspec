lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "pheme/version"

Gem::Specification.new do |s|
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless s.respond_to?(:metadata)

  s.name          = "pheme"
  s.version       = Pheme::VERSION
  s.authors       = ["Peter Graham"]
  s.email         = ["peter@wealthsimple.com"]
  s.description   = 'Ruby AWS SNS publisher + SQS poller & message handler'
  s.summary       = 'Ruby SNS publisher + SQS poller & message handler'
  s.homepage      = "https://github.com/wealthsimple/pheme"

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables   = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.license       = "MIT"

  s.required_ruby_version = '>= 2.4'

  s.add_dependency "activesupport", ">= 4"
  s.add_dependency "aws-sdk-sns", "~> 1.1"
  s.add_dependency "aws-sdk-sqs", "~> 1.3"
  s.add_dependency "recursive-open-struct", "~> 1"
  s.add_dependency "smarter_csv", "~> 1"

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'git'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-collection_matchers'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'rspec_junit_formatter', '~> 0.2'
  s.add_development_dependency 'ws-style'
end
