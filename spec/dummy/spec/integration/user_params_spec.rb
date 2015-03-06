require 'spec_helper'

describe ROM::Model::Attributes do
  let(:params) do
    Class.new do
      include ROM::Model::Attributes

      attribute :name, String

      timestamps
    end
  end

  describe '.timestamps' do
    it 'provides a way to specify timestamps with default values' do
      expect(params.new.created_at).to be_a(DateTime)
      expect(params.new.updated_at).to be_a(DateTime)
    end

    context 'passing in arbritrary names' do
      it 'excludes :created_at when passing in :updated_at' do
        params = Class.new {
          include ROM::Model::Attributes

          timestamps(:updated_at)
        }

        model = params.new

        expect(model).not_to respond_to(:created_at)
        expect(model).to respond_to(:updated_at)
      end

      it 'accepts multiple timestamp attribute names' do
        params = Class.new {
          include ROM::Model::Attributes

          timestamps(:published_at, :revised_at)
        }

        model = params.new

        expect(model).to respond_to(:published_at)
        expect(model).to respond_to(:revised_at)
      end
    end
  end
end
