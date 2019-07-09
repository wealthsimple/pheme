require_relative './example_message_handler'

Pheme::QueuePoller.new(queue_url: 'http://mock_url.test', message_handler: ExampleMessageHandler)
