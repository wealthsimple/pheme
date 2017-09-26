require 'active_support/all'
require 'recursive-open-struct'
require 'aws-sdk-core'
begin
  require 'aws-sdk-sqs' unless defined?(Aws::SQS)
  require 'aws-sdk-sns' unless defined?(Aws::SNS)
rescue LoadError
  fail "AWS SDK 3 requires aws-sdk-sqs and aws-sdk-sqs to be installed separately. Please add gem 'aws-sdk-sqs' and 'aws-sdk-sns' to your Gemfile"
end
require 'securerandom'
require 'smarter_csv'

require 'pheme/version'
require 'pheme/configuration'
require 'pheme/logger'
require 'pheme/rollbar'
require 'pheme/topic_publisher'
require 'pheme/message_handler'
require 'pheme/queue_poller'
