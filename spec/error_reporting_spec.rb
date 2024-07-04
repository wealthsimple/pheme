RSpec.describe Pheme do
  let(:error_reporting_func) { double }

  describe '.capture_exception' do
    subject { described_class.capture_exception(exception, message, data) }

    let(:exception) { StandardError }
    let(:message) { 'Unable to poll for messages' }
    let(:data) { { sqs_url: 'arn::foo::bar' } }

    before do
      described_class.configure do |config|
        config.error_reporting_func = error_reporting_func
      end
    end

    it 'sends error message to configured error_reporter' do
      expect(error_reporting_func).to receive(:call).with(exception, message, data)
      subject
    end
  end
end
