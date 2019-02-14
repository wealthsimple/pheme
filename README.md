# pheme [![CircleCI](https://circleci.com/gh/wealthsimple/pheme.svg?style=svg&circle-token=76942be0b1712ac066627be264886ee18039ad11)](https://circleci.com/gh/wealthsimple/pheme) [![Coverage Status](https://coveralls.io/repos/github/wealthsimple/pheme/badge.svg?branch=3.1.0-rc)](https://coveralls.io/github/wealthsimple/pheme?branch=3.1.0-rc)

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
