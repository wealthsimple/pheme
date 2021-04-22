describe Pheme::QueuePublisher do
  before { use_default_configuration! }

  let(:queue_url) { "https://sqs.us-east-1.amazonaws.com/1234567890/test-queue-url" }

  context "base publisher" do
    subject { described_class.new(queue_url: queue_url) }

    describe ".publish_event" do
      it "does not implement handle" do
        expect { subject.publish_event }.to raise_error(NotImplementedError)
      end
    end

    describe ".publish_events" do
      it "does not implement handle" do
        expect { subject.publish_events }.to raise_error(NotImplementedError)
      end
    end
  end

  describe ".new" do
    context "when initialized with valid params" do
      it "does not raise an error" do
        expect { ExampleQueuePublisher.new(queue_url: queue_url) }.not_to raise_error
      end
    end

    context "when initialized with a nil queue_url" do
      it "raises an ArgumentError" do
        expect { ExampleQueuePublisher.new(queue_url: nil) }.to raise_error(ArgumentError)
      end
    end

    context "when queue_url set via class setter" do
      it "does not raise an error" do
        expect { ExampleWithArnQueuePublisher.new }.not_to raise_error
      end
    end
  end

  describe "#publish_event" do
    subject { ExampleQueuePublisher.new(queue_url: queue_url) }

    it "publishes the correct event" do
      expect(Pheme.configuration.sqs_client).to receive(:send_message).with({
        queue_url: queue_url,
        message_body: { id: "id-1", status: "complete" }.to_json,
        message_attributes: nil,
      })
      subject.publish_event
    end

    context 'with string message' do
      subject { described_class.new(queue_url: queue_url) }

      let(:message) { "don't touch my string" }

      it "publishes unchanged message" do
        expect(Pheme.configuration.sqs_client).to receive(:send_message).with({
          queue_url: queue_url,
          message_body: message,
          message_attributes: nil,
        })
        subject.send_message(message)
      end

      context 'with an explicit sqs client' do
        let(:sqs_client) { double }

        it "publishes unchanged message" do
          expect(sqs_client).to receive(:send_message).with({
            queue_url: queue_url,
            message_body: message,
            message_attributes: nil,
          })
          subject.send_message(message, sqs_client: sqs_client)
        end
      end
    end

    context 'with message too large' do
      subject { described_class.new(queue_url: queue_url).send_message(message) }

      let(:message) { 'x' * (described_class::MESSAGE_SIZE_LIMIT + 1) }

      let(:compressed_message) do
        gz = Zlib::GzipWriter.new(StringIO.new)
        gz << message
        Base64.encode64(gz.close.string)
      end

      it "publishes gzipped, base64 encoded message" do
        expect(Pheme.configuration.sqs_client).to(
          receive(:send_message).
            with({
              queue_url: queue_url,
              message_body: compressed_message,
              message_attributes: nil,
            }),
        )
        subject
      end
    end
  end

  describe "#publish_events" do
    subject { ExampleQueuePublisher.new(queue_url: queue_url) }

    let(:entries) {
      [
        {
          id: "id-1",
          message_body: { id: "message-1", status: "complete" }.to_json,
          message_attributes: nil,
        },
        {
          id: "id-2",
          message_body: { id: "message-2", status: "complete" }.to_json,
          message_attributes: nil,
        },
      ]
    }

    it "publishes the correct events" do
      expect(Pheme.configuration.sqs_client).to receive(:send_message_batch).with({
        queue_url: queue_url,
        entries: entries,
      })
      subject.publish_events
    end
  end
end
