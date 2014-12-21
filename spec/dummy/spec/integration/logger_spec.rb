require 'spec_helper'

describe 'ROM logger' do
  let(:rom) { Rails.application.config.rom.env }

  it 'sets up rails logger for all repositories' do
    pending 'this will be re-enabled once we have feature detection on ' \
      'adapters and in case of missing rails-log-subscriber support we ' \
      'will set logger to Rails.logger'
    rom.repositories.each_value do |repository|
      expect(repository.logger).to be(Rails.logger)
    end
  end
end
