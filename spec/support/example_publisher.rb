class ExamplePublisher < Pheme::TopicPublisher
  def publish_events
    1.upto(3) do |id|
      publish({
        id: "id-#{id}",
        message: "OK",
        sent_at: Time.now,
      })
    end
  end
end
