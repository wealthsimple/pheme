describe Pheme::MessageType::AwsEvent do
  subject { ExampleAwsEventQueuePoller.new }

  describe "#parse_message" do
    context "with JSON message" do
      let!(:message) { OpenStruct.new({ body: "{\"Records\":[{\"eventVersion\":\"2.0\"}]}" }) }

      it 'should parse the message correctly' do
        expect(subject.parse_message(message).first.eventVersion).to eq("2.0")
      end
    end
  end
end
