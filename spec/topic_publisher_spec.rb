describe Pheme::TopicPublisher do
  before(:each) { use_default_configuration! }
  subject { ExamplePublisher.new(topic_arn: "arn:aws:sns:whatever") }

  describe "#publish_events" do
    it "publishes the correct events" do
      expect(Pheme.configuration.sns_client).to receive(:publish).exactly(3).times.with({
        topic_arn: "arn:aws:sns:whatever",
        message: kind_of(String),
      })
      subject.publish_events
    end
  end
end
