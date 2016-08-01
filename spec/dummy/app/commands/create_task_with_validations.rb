class CreateTaskWithValidations < CreateTask
  register_as :create_task_with_validations

  class Validator
    include ROM::Model::Validator

    validates :title, presence: true
  end

  validator Validator
end
