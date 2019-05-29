RSpec.describe Pheme do
  let(:rollbar) { double }

  describe '.rollbar' do
    subject { described_class.rollbar(exception, message, data) }

    let(:exception) { StandardError }
    let(:message) { 'Unable to poll for messages' }
    let(:data) { { sqs_url: 'arn::foo::bar' } }

    before do
      described_class.configure do |config|
        config.rollbar = rollbar
      end
    end

    it 'sends error message to rollbar' do
      expect(rollbar).to receive(:error).with(exception, message, data)
      subject
    end
  end
end
