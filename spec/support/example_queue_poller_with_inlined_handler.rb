Pheme::QueuePoller.new(queue_url: 'http://mock_url.test') do |message, metadata|
  # handle the message
  pp message
  pp metadata
end
