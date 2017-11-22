describe Pheme::MessageType::SnsMessage do
  module SnsMessage
    class Fixture < ExampleQueuePoller
      include Pheme::MessageType::SnsMessage
    end
  end

  subject { SnsMessage::Fixture.new }

  describe "#parse_message" do
    context "with JSON message" do
      let!(:message) { OpenStruct.new({ body: '{"Message":"{\"test\":\"test\"}"}' }) }

      it 'should parse the message correctly' do
        expect(subject.parse_message(message).test).to eq("test")
      end
    end
  end
end
