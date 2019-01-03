class ExamplePublisher < Ws::Pheme::TopicPublisher
  def publish_events
    2.times do |n|
      publish({
        id: "id-#{n}",
        status: "complete",
      })
    end
  end
end
