# pheme [![Circle CI](https://circleci.com/gh/wealthsimple/pheme.svg?style=svg)](https://circleci.com/gh/wealthsimple/pheme)

Ruby SNS publisher + SQS poller & message handler

## installation & config

```ruby
# Gemfile
gem 'pheme'
```

```ruby
# Initializer
aws_config = {
  credentials: Aws::Credentials.new('YOUR_ACCESS_KEY_ID', 'YOUR_SECRET_ACCESS_KEY'),
  region: 'us-east-1',
}
AWS_SNS_CLIENT = Aws::SNS::Client.new(aws_config)
AWS_SQS_CLIENT = Aws::SQS::Client.new(aws_config)

Pheme.configure do |config|
  config.sqs_client = AWS_SQS_CLIENT
  config.sns_client = AWS_SNS_CLIENT
  config.logger = Logger.new(STDOUT) # Optionally replace with your app logger, e.g. `Rails.logger`
end
```

# usage

See https://github.com/wealthsimple/pheme/tree/master/spec/support for example implementations of each class.

TODO: write better usage instructions.
