require 'bundler/setup'
require 'rubocop/rake_task'

task default: %w(app:spec spec:isolated rubocop)

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

desc 'Run isolated specs'
task :"spec:isolated" do
  FileList["spec/isolation/*_spec.rb"].each do |spec|
    sh "rspec", spec
  end
end

RuboCop::RakeTask.new do |task|
  task.options << '--display-cop-names'
  task.options << '--rails'
end
