RSpec.describe Pheme do
  describe '.log' do
    subject { described_class.log(method, text) }

    let(:method) { 'info' }
    let(:text) { 'Some informational message' }

    it { subject }
  end
end
