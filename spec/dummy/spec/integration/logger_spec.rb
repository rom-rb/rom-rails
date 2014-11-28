require 'spec_helper'

describe 'ROM logger' do
  let(:rom) { Rails.application.config.rom.env }

  it 'sets up rails logger for all repositories' do
    rom.repositories.each_value do |repository|
      expect(repository.logger).to be(Rails.logger)
    end
  end
end
