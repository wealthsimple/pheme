RSpec.describe Pheme do
  describe '.log' do
    let(:method) { 'info' }
    let(:text) { 'Some informational message' }

    subject { Pheme.log(method, text) }

    it { subject }
  end
end
