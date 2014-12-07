require 'spec_helper'

describe UsersController, type: :controller do
  describe 'injected relations' do
    it 'exposes relation without required params' do
      get :index

      expect(controller.users).to eql(rom.read(:users).index.to_a)
    end

    it 'exposes relation with required params' do
      get :search, name: 'Jane'

      expect(controller.users).to eql(rom.read(:users).by_name('Jane').to_a)
    end

    it 'halts processing when required params are missing' do
      get :search

      expect(response.status).to be(400)
    end

    it 'skips injecting relation when :only option is used' do
      get :ping

      expect(controller.users).to be(nil)
    end
  end
end
