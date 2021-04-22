class ExampleQueuePublisher < Pheme::QueuePublisher
  def publish_event
    send_message({ id: "id-1", status: "complete" })
  end

  def publish_events
    entries = [1, 2].map do |num|
      message_body = { id: "message-#{num}", status: "complete" }.to_json
      {
        id: "id-#{num}",
        message_body: message_body,
        message_attributes: nil,
      }
    end

    send_message_batch(entries)
  end
end
