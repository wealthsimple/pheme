require 'rspec'

require './lib/pheme'

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    Pheme.reset_configuration!
  end
end

def use_default_configuration!
  Pheme.configure do |config|
    config.sqs_client = double
    config.sns_client = double
    config.logger = Logger.new(nil)
  end
end
