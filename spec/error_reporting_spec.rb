RSpec.describe Pheme do
  let(:ws_railway_error_reporting) { double }

  describe '.capture_exception' do
    subject { described_class.capture_exception(exception, message, data) }

    let(:exception) { StandardError }
    let(:message) { 'Unable to poll for messages' }
    let(:data) { { sqs_url: 'arn::foo::bar' } }

    before do
      described_class.configure do |config|
        config.error_reporting = ws_railway_error_reporting
      end
    end

    it 'sends error message to Ws::Railway::ErrorReporting' do
      expect(ws_railway_error_reporting).to receive(:capture_exception).with(exception, message, data)
      subject
    end
  end
end
