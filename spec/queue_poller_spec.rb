describe Pheme::QueuePoller do
  let(:queue_url) { "https://sqs.us-east-1.amazonaws.com/whatever" }

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
  end

  describe "#extract_notification" do
    let!(:queue_message) { OpenStruct.new(body: { Message: message }.to_json) }
    subject { poller.extract_notification(queue_message) }

    context "message is JSON string" do
      let(:poller) { ExampleQueuePoller.new(queue_url: queue_url, format: :json) }
      let!(:message) { { test: 'test' }.to_json }

      its([:message, 'test']) { is_expected.to eq('test') }
      its(['Message']) { is_expected.to eq(message) }
    end

    context "message is CSV string" do
      let(:poller) { ExampleQueuePoller.new(queue_url: queue_url, format: :csv) }
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

      its([:message]) { is_expected.to have(2).items }
      its([:message]) do
        is_expected.to eq(RecursiveOpenStruct.new({ wrapper: expected_message }, recurse_over_arrays: true).wrapper)
      end
      its(['Message']) { is_expected.to eq(message) }
    end

    context "with unknown message format" do
      let(:poller) { ExampleQueuePoller.new(queue_url: queue_url, format: :invalid_format) }
      let(:message) { 'unkonwn' }

      it "should raise error" do
        expect{ subject }.to raise_error
      end
    end

    context "with array JSON message" do
      let(:poller) { ExampleQueuePoller.new(queue_url: queue_url, format: :json) }
      let(:message) { [[{ test: 'test' }]].to_json }

      it 'should parse the message correctly' do
        expect(subject[:message]).to be_a(Array)
        expect(subject[:message].first).to be_a(Array)
        expect(subject[:message].first.first).to be_a(RecursiveOpenStruct)
        expect(subject[:message].first.first.test).to eq('test')
      end
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

    context "with connection pool block" do
      let(:mock_connection_pool) { double }
      subject { ExampleQueuePoller.new(queue_url: queue_url, connection_pool_block: true) }
      let(:message) { { status: 'complete' } }
      let(:notification) { { 'MessageId' => SecureRandom.uuid, 'Message' => message.to_json, 'Type' => 'Notification' } }
      let(:queue_message) { RecursiveOpenStruct.new(body: notification.to_json) }

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
      let(:notification) { { 'MessageId' => SecureRandom.uuid, 'Message' => message.to_json, 'Type' => 'Notification' } }
      let(:queue_message) { RecursiveOpenStruct.new(body: notification.to_json) }

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
        }
      end
      let(:queue_message) { RecursiveOpenStruct.new(body: notification.to_json) }

      before(:each) do
        allow(subject.queue_poller).to receive(:poll).and_yield(queue_message)
        allow(subject.queue_poller).to receive(:delete_message).with(queue_message)
      end

      it "handles the message" do
        expect(ExampleMessageHandler).to receive(:new).with(message: RecursiveOpenStruct.new(message))
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
        }
      end
      let(:queue_message) { RecursiveOpenStruct.new(body: notification.to_json) }

      before(:each) do
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
  end
end
