RSpec.describe 'ROM logger' do
  let(:rom) { ROM.env }

  it 'sets up rails logger for all gateways' do
    pending 'this will be re-enabled once we have feature detection on ' \
      'adapters and in case of missing rails-log-subscriber support we ' \
      'will set logger to Rails.logger'
    rom.gateways.each_value do |gateway|
      expect(gateway.logger).to be(Rails.logger)
    end
  end
end
