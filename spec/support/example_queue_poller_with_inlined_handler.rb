Pheme::QueuePoller.new(queue_url: 'http://mock_url.test') do |message, metadata, message_attributes|
  # handle the message
  pp message
  pp metadata
  pp message_attributes
end
