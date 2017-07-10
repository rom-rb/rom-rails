class TaskMapper < ROM::Mapper
  relation :tasks
  register_as :task

  model name: 'Task'

  attribute :id
  attribute :title
end
