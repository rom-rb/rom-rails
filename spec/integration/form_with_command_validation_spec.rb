require 'spec_helper'

describe 'Form with command supplied validations' do

  subject(:form) { form_class.build(params) }

  let(:params) {{}}

  let(:form_class) do
    Class.new(ROM::Model::Form) do
      inject_commands_for :tasks

      input do
        set_model_name 'Task'

        attribute :title
      end

      def commit!
        tasks.try { tasks.create_task_with_validations.call(attributes) }
      end
    end
  end


  it "copies validation errors from command" do
    form.save

    errors = form.errors
    expect(errors[:title]).to be_present
  end

end
