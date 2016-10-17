describe Pheme::QueuePoller do
  let(:queue_url) { "https://sqs.us-east-1.amazonaws.com/whatever" }
  let(:poller) do
    poller = double
    allow(poller).to receive(:poll).with(kind_of(Hash))
    allow(poller).to receive(:parse_message)
    poller
  end
  before(:each) do
    use_default_configuration!
    allow(Aws::SQS::QueuePoller).to receive(:new) { poller }
  end

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
  end

  describe "#parse_message" do
    context "with JSON message" do
      subject { ExampleQueuePoller.new(queue_url: queue_url) }

      let!(:message) { OpenStruct.new({
        body: '{"Message":"{\"test\":\"test\"}"}'
      })}

      it 'should parse the message correctly' do
        expect(subject.parse_message(message).test).to eq("test")
      end
    end

    context "with CSV message" do
      subject { ExampleQueuePoller.new(queue_url: queue_url, format: :csv) }

      let!(:message) { OpenStruct.new({
        body:'{"Message":"test,test2\nvalue,value2\nvalue3,value4"}'
      })}

      it 'should parse the message correctly' do
        expect(subject.parse_message(message)).to be_a(Array)
        expect(subject.parse_message(message).count).to eq(2)
      end
    end

    context "with unknown message format" do
      subject { ExampleQueuePoller.new(queue_url: queue_url, format: :invalid_format) }

      let!(:message) { OpenStruct.new({
        body:'{"Message":"test,test2\nvalue,value2\nvalue3,value4"}'
      })}

      it 'should raise an error' do
        expect{ subject.parse_message(message) }.to raise_error
      end
    end
  end

  describe "#poll" do
    before(:each) do
      module ActiveRecord
        class Base
          def self.connection_pool
          end
        end
      end
    end

    context "with connection pool block" do
      let(:mock_connection_pool) { double }

      before(:each) do
        allow(ActiveRecord::Base).to receive(:connection_pool) { mock_connection_pool }
        allow(mock_connection_pool).to receive(:with_connection).and_yield
      end

      subject { ExampleQueuePoller.new(queue_url: queue_url, connection_pool_block: true) }

      it "uses the connection pool block" do
        expect(mock_connection_pool).to receive(:with_connection)
        subject.poll
      end
    end

    context "without connection pool block" do
      subject { ExampleQueuePoller.new(queue_url: queue_url) }

      it "does not call ActiveRecord" do
        expect(ActiveRecord::Base).not_to receive(:connection_pool)
        subject.poll
      end
    end

    context "when a valid message is yielded" do
      let(:message_body) do
        {
          id: "id-123",
          status: "complete",
        }
      end
      let(:message) do
        message = double
        allow(message).to receive(:body) do
          {Message: message_body.to_json,}.to_json
        end
        message
      end
      before(:each) do
        allow(poller).to receive(:poll).and_yield(message)
      end

      subject { ExampleQueuePoller.new(queue_url: queue_url) }

      it "handles the message" do
        expect(ExampleMessageHandler).to receive(:new).with(message: RecursiveOpenStruct.new(message_body))
        subject.poll
      end

      it "deletes the message from the queue" do
        expect(poller).to receive(:delete_message).with(message)
        subject.poll
      end
    end

    context "when an invalid message is yielded" do
      let(:message_body) do
        {
          id: "id-123",
          status: "unknown-abc",
        }
      end
      let(:message) do
        message = double
        allow(message).to receive(:body) do
          {Message: message_body.to_json}.to_json
        end
        message
      end
      before(:each) do
        allow(poller).to receive(:poll).and_yield(message)
        allow(Pheme).to receive(:log)
      end

      subject { ExampleQueuePoller.new(queue_url: queue_url) }

      it "logs the error" do
        subject.poll
        expect(Pheme).to have_received(:log).with(:error, "Exception: #<ArgumentError: Unknown message status: unknown-abc>")
      end

      it "does not delete the message from the queue" do
        expect(poller).not_to receive(:delete_message)
        subject.poll
      end
    end
  end
end
