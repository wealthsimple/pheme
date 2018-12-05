lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "pheme/version"

Gem::Specification.new do |gem|
  gem.name          = "pheme"
  gem.version       = Pheme::VERSION
  gem.authors       = ["Peter Graham"]
  gem.email         = ["peter@wealthsimple.com"]
  gem.description   = 'Ruby AWS SNS publisher + SQS poller & message handler'
  gem.summary       = 'Ruby SNS publisher + SQS poller & message handler'
  gem.homepage      = "https://github.com/wealthsimple/pheme"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.licenses      = ["MIT"]
  gem.required_ruby_version = ">= 2.3.0"

  gem.add_dependency "activesupport", ">= 4"
  gem.add_dependency "aws-sdk-sns", "~> 1.1"
  gem.add_dependency "aws-sdk-sqs", "~> 1.3"
  gem.add_dependency "recursive-open-struct", "~> 1"
  gem.add_dependency "smarter_csv", "~> 1"

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-collection_matchers"
  gem.add_development_dependency "rspec-its"
  gem.add_development_dependency "rspec_junit_formatter", ">= 0", "~> 0.2"
  gem.add_development_dependency "rubocop"
end
