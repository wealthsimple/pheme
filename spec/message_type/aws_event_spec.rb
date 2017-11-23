describe Pheme::MessageType::AwsEvent do
  subject { ExampleAwsEventQueuePoller.new }

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
      let!(:message) { OpenStruct.new({ body: "{\"Records\":[{\"eventVersion\":\"2.0\"}]}" }) }

      it 'should parse the message correctly' do
        expect(subject.parse_message(message).first.eventVersion).to eq("2.0")
      end
    end
  end
end
