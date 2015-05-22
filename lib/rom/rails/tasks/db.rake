namespace :db do
  desc 'Set up ROM repositories'
  task :setup do
    railtie = ROM::Rails::Railtie
    railtie.before_initialize

    require "#{Rails.root}/config/initializers/rom"

    railtie.setup_repositories.finalize
  end
end
