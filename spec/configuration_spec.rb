describe Pheme do
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

  describe Pheme::Configuration do
    describe '.validate!' do
      subject { configuration.validate! }

      let(:configuration) { Pheme::Configuration.new }

      context 'empty configuration' do
        it 'is invalid when empty' do
          expect { subject }.to raise_error(StandardError)
        end
      end

      context 'all mandatory attributes provided' do
        let(:sns_client) { instance_double('Aws::SNS::Client') }
        let(:sqs_client) { instance_double('Aws::SQS::Client') }

        before do
          allow(sns_client).to receive(:is_a?).with(Aws::SNS::Client).and_return(true)
          allow(sqs_client).to receive(:is_a?).with(Aws::SQS::Client).and_return(true)

          configuration.sns_client = sns_client
          configuration.sqs_client = sqs_client
        end

        it 'is valid' do
          expect { subject }.not_to raise_error
        end
      end
    end
  end
end
