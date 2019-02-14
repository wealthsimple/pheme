RSpec.describe Pheme do
  let(:rollbar) { double }

  describe '.rollbar' do
    let(:exception) { StandardError }
    let(:message) { 'Unable to poll for messages' }
    let(:data) { { sqs_url: 'arn::foo::bar' } }

    before do
      Pheme.configure do |config|
        config.rollbar = rollbar
      end
    end

    subject { Pheme.rollbar(exception, message, data) }

    it 'sends error message to rollbar' do
      expect(rollbar).to receive(:error).with(exception, message, data)
      subject
    end
  end
end
