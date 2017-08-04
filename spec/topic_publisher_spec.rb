describe Pheme::TopicPublisher do
  before(:each) { use_default_configuration! }

  describe ".new" do
    context "when initialized with valid params" do
      it "does not raise an error" do
        expect { ExamplePublisher.new(topic_arn: "arn:aws:sns:whatever") }.not_to raise_error
      end
    end

    context "when initialized with a nil topic_arn" do
      it "raises an ArgumentError" do
        expect { ExamplePublisher.new(topic_arn: nil) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#publish_events" do
    subject { ExamplePublisher.new(topic_arn: "arn:aws:sns:whatever") }

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

    context 'with string message' do
      let(:topic_arn) { "arn:aws:sns:anything" }
      let(:message) { "don't touch my string" }

      subject {Pheme::TopicPublisher.new(topic_arn: topic_arn)}

      it "publishes unchanged message" do
        expect(Pheme.configuration.sns_client).to receive(:publish).with({
                                                                           topic_arn: topic_arn,
                                                                           message: message,
                                                                         })
        subject.publish(message)
      end
    end
  end
end
