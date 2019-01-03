describe Ws::Pheme::MessageHandler do
  before(:each) { use_default_configuration! }
  let(:message) { RecursiveOpenStruct.new(status: "complete") }
  let(:timestamp) { '2018-04-17T21:45:05.915Z' }
  subject { ExampleMessageHandler.new(message: message, metadata: { timestamp: timestamp }) }

  describe "#handle" do
    it "handles the message correctly" do
      expect(Ws::Pheme.logger).to receive(:info).with("Done")
      subject.handle
    end
  end
end
