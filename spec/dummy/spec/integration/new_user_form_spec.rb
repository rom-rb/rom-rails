require 'spec_helper'

describe NewUserForm do
  subject(:form) { NewUserForm.build(params) }

  let(:params) do
    { name: 'Jane', email: 'jane@doe.org' }
  end

  describe '#save' do
    it 'persists attributes and auto-map result to entity object' do
      form.save

      user = form.result.value

      expect(user).to eql(User.new(id: 1, name: 'Jane', email: 'jane@doe.org'))
    end
  end
end
