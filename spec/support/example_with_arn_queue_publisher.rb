class ExampleWithArnQueuePublisher < Pheme::QueuePublisher
  queue_url "https://sqs.us-east-1.amazonaws.com/1234567890/test-queue-url"
end
