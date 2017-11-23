class ExampleQueuePoller < Pheme::QueuePoller
  def initialize(queue_url: 'http://mock_url.test', **kwargs)
    super(queue_url: queue_url, **kwargs)
  end

  def handle(message)
    case message.status
    when 'complete', 'rejected'
      ExampleMessageHandler.new(message: message).handle
    else
      raise ArgumentError, "Unknown message status: #{message.status}"
    end
  end
end
