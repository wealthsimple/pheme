describe Pheme::TopicPublisher do
  before { use_default_configuration! }

  context 'base publisher' do
    subject { described_class.new(topic_arn: 'arn::foo::bar').publish_events }

    it 'does not implement handle' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

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

    context "when topic_arn set via class setter" do
      it "does not raise an error" do
        expect { ExampleWithArnPublisher.new }.not_to raise_error
      end
    end
  end

  describe "#publish_events" do
    subject { ExamplePublisher.new(topic_arn: "arn:aws:sns:whatever") }

    it "publishes the correct events" do
      expect(Pheme.configuration.sns_client).to receive(:publish).with({
        topic_arn: "arn:aws:sns:whatever",
        message: { id: "id-0", status: "complete" }.to_json,
        message_attributes: nil,
        message_deduplication_id: nil,
        message_group_id: nil,
      })
      expect(Pheme.configuration.sns_client).to receive(:publish).with({
        topic_arn: "arn:aws:sns:whatever",
        message: { id: "id-1", status: "complete" }.to_json,
        message_attributes: nil,
        message_deduplication_id: nil,
        message_group_id: nil,
      })
      subject.publish_events
    end

    context 'with string message' do
      subject { described_class.new(topic_arn: topic_arn) }

      let(:topic_arn) { "arn:aws:sns:anything" }
      let(:message) { "don't touch my string" }

      it "publishes unchanged message" do
        expect(Pheme.configuration.sns_client).to receive(:publish).with({
          topic_arn: topic_arn,
          message: message,
          message_attributes: nil,
          message_deduplication_id: nil,
          message_group_id: nil,
        })
        subject.publish(message)
      end

      context 'with an explicit sns client' do
        let(:sns_client) { double }

        it "publishes unchanged message" do
          expect(sns_client).to receive(:publish).with({
            topic_arn: topic_arn,
            message: message,
            message_attributes: nil,
            message_deduplication_id: nil,
            message_group_id: nil,
          })
          subject.publish(message, sns_client: sns_client)
        end
      end
    end

    context 'with message too large' do
      subject { described_class.new(topic_arn: topic_arn).publish(message) }

      let(:topic_arn) { "arn:aws:sns:anything" }
      let(:message) { 'x' * (described_class::MESSAGE_SIZE_LIMIT + 1) }

      let(:compressed_message) do
        gz = Zlib::GzipWriter.new(StringIO.new)
        gz << message
        Base64.encode64(gz.close.string)
      end

      it "publishes gzipped, base64 encoded message" do
        expect(Pheme.configuration.sns_client).to(
          receive(:publish).
            with({
              topic_arn: topic_arn,
              message: compressed_message,
              message_attributes: nil,
              message_deduplication_id: nil,
              message_group_id: nil,
            }),
        )

        subject
      end
    end
  end
end
