describe Ws::Pheme::MessageType::SnsMessage do
  module SnsMessage
    class Fixture < ExampleQueuePoller
      include Ws::Pheme::MessageType::SnsMessage
    end
  end

  subject { SnsMessage::Fixture.new }

  let(:poller) do
    poller = double
    allow(poller).to receive(:poll).with(kind_of(Hash))
    allow(poller).to receive(:parse_message)
    allow(poller).to receive(:before_request)
    poller
  end

  before(:each) do
    use_default_configuration!
    allow(Aws::SQS::QueuePoller).to receive(:new) { poller }
  end

  describe "#parse_message" do
    context "with JSON message" do
      let!(:message) { OpenStruct.new({ body: '{"Message":"{\"test\":\"test\"}"}' }) }

      it 'should parse the message correctly' do
        expect(subject.parse_body(message).test).to eq("test")
      end
    end
  end
end
