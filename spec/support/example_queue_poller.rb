class ExampleQueuePoller < Pheme::QueuePoller
  def handle(message)
    case message.status
    when 'complete', 'rejected'
      ExampleMessageHandler.new(message: message).handle
    else
      raise ArgumentError, "Unknown message status: #{message.status}"
    end
  end
end
