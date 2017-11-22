#
# Example for pollers that consume internal AWS Events,
# like S3 notifications, CloudWatch events, etc.
#
# This poller's output message will be a list of hashes,
# each containing one event.
#
class ExampleAwsEventQueuePoller < ExampleQueuePoller
  include Pheme::MessageType::AwsEvent
end
