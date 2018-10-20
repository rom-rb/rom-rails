RSpec.describe "including controller extensions" do
  describe "An application controller" do
    let(:controller) do
      Class.new(ActionController::Base)
    end

    it "includes the controller extensions" do
      expect(controller.ancestors).to include(ROM::Rails::ControllerExtension)
    end
  end

  if defined?(ActionController::API)
    describe "An API controller" do
      let(:controller) do
        Class.new(ActionController::API)
      end

      it "includes the controller extensions" do
        expect(controller.ancestors).to include(ROM::Rails::ControllerExtension)
      end
    end
  end
end
