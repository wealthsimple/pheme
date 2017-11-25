describe Pheme::MessageType::AwsEvent do
  let(:poller) { ExampleAwsEventQueuePoller.new }
  let(:message_id) { SecureRandom.uuid }
  let(:queue_url) { 'http://queue_url' }
  let(:queue_message) do
    OpenStruct.new(
      message_id: message_id,
      body: { 'Records' => records }.to_json,
      queue_url: queue_url,
    )
  end

  describe "#parse_body" do
    subject { poller.parse_body(queue_message) }

    context "with JSON message" do
      let!(:records) { [{ 'eventVersion' => '2.0' }] }
      its('first.eventVersion') { is_expected.to eq('2.0') }
    end
  end
end
