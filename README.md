# pheme [![GitHub Actions Workflow Badge](https://github.com/wealthsimple/pheme/actions/workflows/master-workflow.yml/badge.svg)](https://github.com/wealthsimple/pheme/actions)

Ruby SNS publisher + SQS poller & message handler

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'pheme'
```

And then execute:
```bash
$ bundle
```

## Configuration

```ruby
# Initializer
aws_config = {
  credentials: Aws::Credentials.new('YOUR_ACCESS_KEY_ID', 'YOUR_SECRET_ACCESS_KEY'),
  region: 'us-east-1', # Enter your AWS region here
}
Aws.config.update(aws_config)
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

### Handling SQS messages

Pheme expects that the SQS messages it is handling will have first been published to an SNS topic
before being sent to the SQS queue. This means if the service publishing messages is publishing them
**directly** to the SQS queue, that service must nest the message payload underneath a `Message` property.
