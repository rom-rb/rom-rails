require 'rom'

module ROM
  class << self
    attr_accessor :env
  end
end

require 'rom/rails/version'
require 'rom/rails/railtie'
require 'rom/rails/model/form'
