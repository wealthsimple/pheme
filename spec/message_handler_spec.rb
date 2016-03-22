describe Pheme::MessageHandler do
  before(:each) { use_default_configuration! }
  let(:message) { RecursiveOpenStruct.new(status: "complete") }
  subject { ExampleMessageHandler.new(message: message) }

  describe "#handle" do
    it "handles the message without raising an error" do
      expect { subject.handle }.not_to raise_error
    end
  end
end
