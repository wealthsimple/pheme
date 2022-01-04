describe Pheme::MessageHandler do
  subject { ExampleMessageHandler.new(message: message, metadata: { timestamp: timestamp }) }

  before { use_default_configuration! }

  let(:message) { RecursiveOpenStruct.new(status: status) } # rubocop:todo Vendor/RecursiveOpenStructUse
  let(:timestamp) { '2018-04-17T21:45:05.915Z' }

  describe "#handle" do
    context 'complete message' do
      let(:status) { 'complete' }

      it "handles the message correctly" do
        expect(Pheme.logger).to receive(:info).with("Done")
        subject.handle
      end
    end

    context 'rejected message' do
      let(:status) { 'rejected' }

      it 'handles the message correctly' do
        expect(Pheme.logger).to receive(:error).with("Oops")
        subject.handle
      end
    end

    context 'base handler' do
      subject { described_class.new(message: nil).handle }

      it 'does not implement handle' do
        expect { subject }.to raise_error(NotImplementedError)
      end
    end
  end
end
