describe Pheme::MessageHandler do
  before(:each) { use_default_configuration! }
  let(:message) { RecursiveOpenStruct.new(status: "complete") }
  subject { ExampleMessageHandler.new(message: message) }

  describe "#handle" do
    it "handles the message correctly" do
      expect(Pheme.logger).to receive(:info).with("Done")
      subject.handle
    end
  end
end
