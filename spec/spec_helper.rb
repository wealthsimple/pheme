require 'rspec'
require 'rspec/collection_matchers'
require 'rspec/its'
require 'timecop'

Dir["./spec/support/**/*.rb"].each { |f| require f }

require './lib/pheme'

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
