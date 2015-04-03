require 'spec_helper'

describe 'Form with injected commands' do
  subject(:form) { form_class.build(params) }

  let(:params) { { title: 'Task one' } }

  let(:form_class) do
    Class.new(ROM::Model::Form) do
      commands users: :create

      inject_commands_for :tasks

      mappings tasks: :entity

      input do
        set_model_name 'Task'

        attribute :title
      end

      def commit!
        tasks.create[attributes]
      end
    end
  end

  it 'auto-maps result using injected commands' do
    form.save

    value = form.result

    expect(value).to be_a(Task)
    expect(value.id).to_not be(nil)
    expect(value.title).to eql('Task one')
  end
end
