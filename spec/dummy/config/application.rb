require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'

Bundler.setup(:default, Rails.env)

require 'rom-sql'
require 'rom-rails'
require 'rspec-rails'
require 'dry/core/equalizer'

module Dummy
  class Application < Rails::Application
    require 'rom/test_adapter'
  end
end
