class TaskMapper < ROM::Mapper
  relation :tasks
  register_as :entity

  model name: 'Task'

  attribute :id
  attribute :title
end
