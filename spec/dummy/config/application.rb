require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'

Bundler.setup(:default, Rails.env)

require 'rom-sql'
require 'rom-rails'
require 'rspec-rails'

module Dummy
  class Application < Rails::Application
    config.assets.enabled = false

    require 'rom/test_adapter'
  end
end
