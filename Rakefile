require 'bundler/setup'
require 'rubocop/rake_task'

task default: %w(app:spec app:isolation rubocop)

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

RuboCop::RakeTask.new do |task|
  task.options << '--display-cop-names'
  task.options << '--rails'
end
