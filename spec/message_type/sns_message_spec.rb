describe Pheme::MessageType::SnsMessage do
  subject { SnsMessage::Fixture.new }

  let(:poller) do
    poller = double
    allow(poller).to receive(:poll).with(kind_of(Hash))
    allow(poller).to receive(:parse_message)
    allow(poller).to receive(:before_request)
    poller
  end

  before do
    test_class = Class.new(ExampleQueuePoller) do
      include Pheme::MessageType::SnsMessage
    end

    stub_const('SnsMessage::Fixture', test_class)

    use_default_configuration!
    allow(Aws::SQS::QueuePoller).to receive(:new) { poller }
  end

  describe "#parse_message" do
    context "with JSON message" do
      let!(:message) { ResourceStruct::FlexStruct.new({ body: '{"Message":"{\"test\":\"test\"}"}' }) }

      it 'parses the message correctly' do
        expect(subject.parse_body(message).test).to eq("test")
      end
    end
  end
end
