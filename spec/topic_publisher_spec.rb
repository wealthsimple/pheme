describe Ws::Pheme::TopicPublisher do
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

    context "when topic_arn set via class setter" do
      it "does not raise an error" do
        expect { ExampleWithArnPublisher.new }.not_to raise_error
      end
    end
  end

  describe "#publish_events" do
    subject { ExamplePublisher.new(topic_arn: "arn:aws:sns:whatever") }

    it "publishes the correct events" do
      expect(Ws::Pheme.configuration.sns_client).to receive(:publish).with({
        topic_arn: "arn:aws:sns:whatever",
        message: { id: "id-0", status: "complete" }.to_json,
      })
      expect(Ws::Pheme.configuration.sns_client).to receive(:publish).with({
        topic_arn: "arn:aws:sns:whatever",
        message: { id: "id-1", status: "complete" }.to_json,
      })
      subject.publish_events
    end
  end

  describe "#publish" do
    let(:topic_arn) { "arn:aws:sns:anything" }
    let(:message) { "don't touch my string" }
    subject { Ws::Pheme::TopicPublisher.new(topic_arn: topic_arn).publish(message) }

    context 'with string message' do
      it "publishes unchanged message" do
        expect(Ws::Pheme.configuration.sns_client).to receive(:publish).with({
          topic_arn: topic_arn,
          message: message,
        })
        subject
      end
    end

    context 'with message too large' do
      let(:message) { 'x' * (described_class::MESSAGE_SIZE_LIMIT + 1) }
      let(:compressed_message) do
        gz = Zlib::GzipWriter.new(StringIO.new)
        gz << message
        Base64.encode64(gz.close.string)
      end

      it "publishes gzipped, base64 encoded message" do
        expect(Ws::Pheme.configuration.sns_client).to(
          receive(:publish).
            with({
              topic_arn: topic_arn,
              message: compressed_message,
            }),
        )

        subject
      end
    end

    context 'retries on Errno::EBADF' do
      it "one retry" do
        call_count = 0
        allow(Ws::Pheme.configuration.sns_client).to receive(:publish) do
          call_count += 1
          raise Errno::EBADF if call_count <= 1
        end
        expect(Ws::Pheme.configuration.sns_client).to receive(:publish).twice
        subject
      end

      it "never succeeds" do
        allow(Ws::Pheme.configuration.sns_client).to receive(:publish).and_raise(Errno::EBADF)
        expect(Ws::Pheme.configuration.sns_client).to receive(:publish).at_most(3).times

        expect { subject }.to raise_error(Errno::EBADF)
      end
    end
  end
end
