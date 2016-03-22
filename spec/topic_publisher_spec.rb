describe Pheme::TopicPublisher do
  before(:each) { use_default_configuration! }
  subject { ExamplePublisher.new(topic_arn: "arn:aws:sns:whatever") }

  describe "#publish_events" do
    it "publishes the correct events" do
      expect(Pheme.configuration.sns_client).to receive(:publish).with({
        topic_arn: "arn:aws:sns:whatever",
        message: {id: "id-0", status: "complete"}.to_json,
      })
      expect(Pheme.configuration.sns_client).to receive(:publish).with({
        topic_arn: "arn:aws:sns:whatever",
        message: {id: "id-1", status: "complete"}.to_json,
      })
      subject.publish_events
    end
  end
end
