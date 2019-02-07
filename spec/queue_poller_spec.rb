describe Ws::Pheme::QueuePoller do
  let(:queue_url) { "https://sqs.us-east-1.amazonaws.com/whatever" }
  let(:timestamp) { '2018-04-17T21:45:05.915Z' }

  describe ".new" do
    context "when initialized with valid params" do
      it "does not raise an error" do
        expect { ExampleQueuePoller.new(queue_url: "queue_url") }.not_to raise_error
      end
    end

    context "when initialized with a nil queue_url" do
      it "raises an ArgumentError" do
        expect { ExampleQueuePoller.new(queue_url: nil) }.to raise_error(ArgumentError)
      end
    end

    context "when initialized with max_messages" do
      it "should set max_messages" do
        expect(ExampleQueuePoller.new(queue_url: "queue_url", max_messages: 5).max_messages).to eq(5)
      end
    end

    context "when initialized with sqs_client" do
      let(:sqs_client) { Object.new }

      it "should set custom sqs_client" do
        expect(Aws::SQS::QueuePoller).to receive(:new).with("queue_url", client: sqs_client)
        ExampleQueuePoller.new(queue_url: "queue_url", sqs_client: sqs_client)
      end
    end
  end

  let(:poller) { ExampleQueuePoller.new(queue_url: queue_url, format: format) }
  let(:message_id) { SecureRandom.uuid }
  let(:message) { nil }
  let!(:queue_message) do
    OpenStruct.new(
      body: { Message: message }.to_json,
      message_id: message_id,
    )
  end

  describe "#parse_body" do
    subject { poller.parse_body(queue_message) }

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

      it "should raise error" do
        expect{ subject }.to raise_error(ArgumentError)
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
    before(:each) do
      module ActiveRecord
        class Base
          def self.connection_pool; end
        end
      end
    end

    context 'retries on Errno::EBADF' do
      subject { ExampleQueuePoller.new(queue_url: queue_url, connection_pool_block: false) }
      let(:message) { { status: 'complete' } }
      let(:notification) { { 'MessageId' => SecureRandom.uuid, 'Message' => message.to_json, 'Type' => 'Notification', 'Timestamp' => timestamp } }
      let!(:queue_message) do
        OpenStruct.new(
          body: notification.to_json,
          message_id: message_id,
        )
      end

      before(:each) do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
      end

      it "one retry" do
        call_count = 0
        allow(subject.queue_poller).to receive(:delete_message) do
          call_count += 1
          raise Errno::EBADF if call_count <= 1

          return queue_message
        end
        expect(subject.queue_poller).to receive(:delete_message).twice
        subject.poll
      end

      it "never succeeds" do
        allow(subject.queue_poller).to receive(:delete_message).and_raise(Errno::EBADF)
        expect(subject.queue_poller).to receive(:delete_message).at_most(3).times
        subject.poll
      end
    end

    context "with connection pool block" do
      let(:mock_connection_pool) { double }
      subject { ExampleQueuePoller.new(queue_url: queue_url, connection_pool_block: true) }
      let(:message) { { status: 'complete' } }
      let(:notification) { { 'MessageId' => SecureRandom.uuid, 'Message' => message.to_json, 'Type' => 'Notification', 'Timestamp' => timestamp } }
      let!(:queue_message) do
        OpenStruct.new(
          body: notification.to_json,
          message_id: message_id,
        )
      end

      before(:each) do
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

      before(:each) do
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

      before(:each) do
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

      before(:each) do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete).with(queue_message)
        allow(Ws::Pheme.logger).to receive(:error)
      end

      it "logs the error" do
        subject.poll
        expect(Ws::Pheme.logger).to have_received(:error) do |error|
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
      before(:each) do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete).with(queue_message)
      end

      it "logs the message" do
        subject.poll
      end
    end
  end
end
