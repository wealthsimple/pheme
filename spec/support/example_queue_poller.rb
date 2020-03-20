class ExampleQueuePoller < Pheme::QueuePoller
  def initialize(queue_url: 'http://mock_url.test', **kwargs)
    super(queue_url: queue_url, **kwargs)
  end

  def handle(message, metadata, message_attributes)
    case message.status
    when 'complete', 'rejected'
      ExampleMessageHandler.new(message: message, metadata: metadata, message_attributes: message_attributes).handle
    else
      raise ArgumentError, "Unknown message status: #{message.status}"
    end
  end
end
