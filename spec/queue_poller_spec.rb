describe Pheme::QueuePoller do
  let(:valid_queue_poller) { ExampleQueuePoller.new(queue_url: queue_url) }
  let(:queue_url) { "https://sqs.us-east-1.amazonaws.com/whatever" }
  let(:timestamp) { '2018-04-17T21:45:05.915Z' }

  let!(:queue_message) do
    OpenStruct.new(
      body: { Message: message }.to_json,
      message_id: message_id,
    )
  end
  let(:message) { nil }
  let(:message_id) { SecureRandom.uuid }

  context 'base poller' do
    subject { described_class.new(queue_url: queue_url).handle(nil, nil) }

    it 'does not implement handle' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe ".new" do
    context "when initialized with valid params" do
      it "does not raise an error" do
        expect { valid_queue_poller }.not_to raise_error
      end
    end

    context "when initialized with a nil queue_url" do
      it "raises an ArgumentError" do
        expect { ExampleQueuePoller.new(queue_url: nil) }.to raise_error(ArgumentError)
      end
    end

    context "when initialized with max_messages" do
      it "sets max_messages" do
        expect(ExampleQueuePoller.new(queue_url: queue_url, max_messages: 5).max_messages).to eq(5)
      end
    end

    context "when initialized with sqs_client" do
      let(:sqs_client) { Object.new }

      it "sets custom sqs_client" do
        expect(Aws::SQS::QueuePoller).to receive(:new).with(queue_url, client: sqs_client)
        ExampleQueuePoller.new(queue_url: queue_url, sqs_client: sqs_client)
      end
    end

    context 'received too many messages' do
      subject { described_class.new(queue_url: queue_url, max_messages: max_messages) }

      let(:aws_poller) { instance_double('Aws::SQS::QueuePoller') }
      let(:max_messages) { 50 }

      before do
        allow(Aws::SQS::QueuePoller).to receive(:new).and_return(aws_poller)
        allow(aws_poller).to receive(:before_request).and_yield(OpenStruct.new(received_message_count: max_messages))
      end

      it 'throws error' do
        expect { subject }.to raise_error(UncaughtThrowError, /stop_polling/)
      end
    end

    context 'when given an idle_timeout' do
      subject { ExampleQueuePoller.new(queue_url: queue_url, idle_timeout: idle_timeout).poller_configuration[:idle_timeout] }

      context 'when given a number' do
        let(:idle_timeout) { 5 }

        it { is_expected.to eq(5) }
      end

      context 'when given nil' do
        let(:idle_timeout) { nil }

        it { is_expected.to eq(20) }
      end

      context 'when given false' do
        let(:idle_timeout) { false }

        it { is_expected.to be(false) }
      end
    end

    context 'when handling messages' do
      context 'when doing it the old way, via the handle function' do
        it 'uses the handle function by default' do
          expect { described_class.new(queue_url: queue_url).handle(nil, nil) }.to raise_error(NotImplementedError)
        end
      end

      context 'when given a message_handler as parameter' do
        it 'uses default when given nil' do
          expect { described_class.new(queue_url: queue_url, message_handler: nil).handle(nil, nil) }.to raise_error(NotImplementedError)
        end

        it 'uses default when given invalid message_handler' do
          expect { described_class.new(queue_url: queue_url, message_handler: Hash) }.to raise_error(ArgumentError)
        end

        it 'uses handler when given one' do
          mock_handler = double('MessageHandler')
          allow(mock_handler).to receive(:handle)
          allow(ExampleMessageHandler).to receive(:new).with(message: 'message', metadata: 'metadata').and_return(mock_handler)

          described_class.new(queue_url: queue_url, message_handler: ExampleMessageHandler).handle('message', 'metadata')
          expect(mock_handler).to have_received(:handle).once
        end
      end

      context 'when given a message_handler as block' do
        it 'uses handler when given one' do
          mock_handler = spy('MessageHandler')

          poller = described_class.new(queue_url: queue_url) do |message, metadata|
            mock_handler.process(message, metadata)
          end
          poller.handle('message', 'metadata')

          expect(mock_handler).to have_received(:process).with('message', 'metadata').once
        end

        it 'fails on invalid handler' do
          expect do
            described_class.new(queue_url: queue_url, message_handler: ExampleMessageHandler) { raise Error('should never happen') }
          end.to raise_error(ArgumentError, 'only provide a message_handler or a block, not both')
        end
      end
    end
  end

  describe "#parse_body" do
    subject { poller.parse_body(queue_message) }

    let(:format) { nil }
    let(:poller) { described_class.new(queue_url: queue_url, format: format) }

    context "message is JSON string" do
      let(:format) { :json }
      let!(:message) { { test: 'test' }.to_json }

      its([:test]) { is_expected.to eq('test') }
    end

    context "message is CSV string" do
      let(:format) { :csv }
      let(:expected_message) do
        [
          { test1: 'value1', test2: 'value2' },
          { test1: 'value3', test2: 'value4' },
        ]
      end
      let(:message) do
        [
          %w[test1 test2].join(','),
          %w[value1 value2].join(','),
          %w[value3 value4].join(','),
        ].join("\n")
      end

      it { is_expected.to have(2).items }
      it { is_expected.to eq(RecursiveOpenStruct.new({ wrapper: expected_message }, recurse_over_arrays: true).wrapper) }
    end

    context "with unknown message format" do
      let(:format) { :invalid_format }
      let(:message) { 'unkonwn' }

      it "raises error" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "with array JSON message" do
      let(:format) { :json }
      let(:message) { [[{ test: 'test' }]].to_json }

      it { is_expected.to be_a(Array) }
      its(:first) { is_expected.to be_a(Array) }
      its('first.first') { is_expected.to be_a(RecursiveOpenStruct) }
      it "parses the nested object" do
        expect(subject.first.first.test).to eq('test')
      end
    end

    context "with compressed body" do
      let(:format) { :json }
      let(:message) do
        gz = Zlib::GzipWriter.new(StringIO.new)
        gz << { test: 'test' }.to_json
        Base64.encode64(gz.close.string)
      end

      its([:test]) { is_expected.to eq('test') }
    end
  end

  describe "#poll" do
    before do
      active_record_stub = Class.new do
        def connection_pool; end
      end

      stub_const('ActiveRecord::Base', active_record_stub)
    end

    context "with connection pool block" do
      subject { ExampleQueuePoller.new(queue_url: queue_url, connection_pool_block: true) }

      let(:mock_connection_pool) { double }

      let(:message) { { status: 'complete' } }
      let(:notification) { { 'MessageId' => SecureRandom.uuid, 'Message' => message.to_json, 'Type' => 'Notification', 'Timestamp' => timestamp } }
      let!(:queue_message) do
        OpenStruct.new(
          body: notification.to_json,
          message_id: message_id,
        )
      end

      before do
        allow(ActiveRecord::Base).to receive(:connection_pool) { mock_connection_pool }
        allow(mock_connection_pool).to receive(:with_connection).and_yield
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete_message).with(queue_message)
      end

      it "uses the connection pool block" do
        expect(mock_connection_pool).to receive(:with_connection)
        subject.poll
      end
    end

    context "without connection pool block" do
      subject { ExampleQueuePoller.new(queue_url: queue_url) }

      let(:message) { { status: 'complete' } }
      let(:notification) { { 'MessageId' => SecureRandom.uuid, 'Message' => message.to_json, 'Type' => 'Notification', 'Timestamp' => timestamp } }
      let!(:queue_message) do
        OpenStruct.new(
          body: notification.to_json,
          message_id: message_id,
        )
      end

      before do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete_message).with(queue_message)
      end

      it "does not call ActiveRecord" do
        expect(ActiveRecord::Base).not_to receive(:connection_pool)
        subject.poll
      end
    end

    context "when a valid message is yielded" do
      subject { ExampleQueuePoller.new(queue_url: queue_url) }

      let(:message) { { id: "id-123", status: "complete" } }
      let(:notification) do
        {
          'MessageId' => SecureRandom.uuid,
          'Message' => message.to_json,
          'Type' => 'Notification',
          'Timestamp' => timestamp,
        }
      end
      let!(:queue_message) do
        OpenStruct.new(
          body: notification.to_json,
          message_id: message_id,
        )
      end

      before do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete_message).with(queue_message)
      end

      it "handles the message" do
        expect(ExampleMessageHandler).to receive(:new).with(message: RecursiveOpenStruct.new(message), metadata: { timestamp: timestamp })
        subject.poll
      end

      it "deletes the message from the queue" do
        expect(subject.queue_poller).to receive(:delete_message).with(queue_message)
        subject.poll
      end
    end

    context "when an invalid message is yielded" do
      subject { ExampleQueuePoller.new(queue_url: queue_url) }

      let(:message) { { id: "id-123", status: "unknown-abc" } }
      let(:notification) do
        {
          'MessageId' => SecureRandom.uuid,
          'Message' => message.to_json,
          'Type' => 'Notification',
          'Timestamp' => timestamp,
        }
      end
      let!(:queue_message) do
        OpenStruct.new(
          body: notification.to_json,
          message_id: message_id,
        )
      end

      before do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete).with(queue_message)
        allow(Pheme.logger).to receive(:error)
      end

      it "logs the error" do
        subject.poll
        expect(Pheme.logger).to have_received(:error) do |error|
          expect(error).to be_a(ArgumentError)
          expect(error.message).to eq('Unknown message status: unknown-abc')
        end
      end

      it "does not delete the message from the queue" do
        expect(subject.queue_poller).not_to receive(:delete_message)
        subject.poll
      end
    end

    context "AWS-event message" do
      subject { ExampleAwsEventQueuePoller.new(queue_url: queue_url) }

      let(:queue_message) { OpenStruct.new(body: { 'Records' => records }.to_json) }
      let(:records) do
        [{ 'eventVersion' => '2.0', 'eventSource': 'aws:s3' }]
      end

      before do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete).with(queue_message)
      end

      it "logs the message" do
        subject.poll
      end
    end

    context 'SignalException' do
      subject { ExampleQueuePoller.new(queue_url: queue_url) }

      let(:message) { { status: 'complete' } }
      let(:notification) { { 'MessageId' => SecureRandom.uuid, 'Message' => message.to_json, 'Type' => 'Notification', 'Timestamp' => timestamp } }
      let!(:queue_message) do
        OpenStruct.new(
          body: notification.to_json,
          message_id: message_id,
        )
      end

      before do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete_message).and_raise(SignalException.new('KILL'))
      end

      it 'stops polling' do
        expect { subject.poll }.to raise_error(UncaughtThrowError, /stop_polling/)
      end
    end
  end
end
