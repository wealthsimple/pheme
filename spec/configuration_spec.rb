describe Pheme do
  describe ".configure" do
    let(:sns_client) { Aws::SNS::Client }
    let(:sqs_client) { Aws::SQS::Client }
    it "sets global configuration" do
      expect(described_class.configuration.sns_client).to be_nil
      expect(described_class.configuration.sqs_client).to be_nil

      described_class.configure do |config|
        config.sns_client = sns_client
        config.sqs_client = sqs_client
      end

      expect(described_class.configuration.sns_client).to eq(sns_client)
      expect(described_class.configuration.sqs_client).to eq(sqs_client)
    end
  end
end
