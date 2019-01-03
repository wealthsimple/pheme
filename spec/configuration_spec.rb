describe Ws::Pheme do
  describe ".configure" do
    let(:sns_client) { double }
    let(:sqs_client) { double }
    let(:custom_logger) { double }
    it "sets global configuration" do
      expect(described_class.configuration.sns_client).to be_nil
      expect(described_class.configuration.sqs_client).to be_nil
      expect(described_class.configuration.logger).to be_a(Logger)

      described_class.configure do |config|
        config.sns_client = sns_client
        config.sqs_client = sqs_client
        config.logger = custom_logger
      end

      expect(described_class.configuration.sns_client).to eq(sns_client)
      expect(described_class.configuration.sqs_client).to eq(sqs_client)
      expect(described_class.configuration.logger).to eq(custom_logger)
    end
  end
end
