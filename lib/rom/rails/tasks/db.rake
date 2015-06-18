namespace :db do
  desc 'Set up ROM gateways'
  task :setup do
    ROM::Rails::Railtie.load_initializer
    ROM::Rails::Railtie.setup_gateways
  end
end
