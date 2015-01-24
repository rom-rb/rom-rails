module ROM
  module Model
    class ValidationError < CommandError
      include Charlatan.new(:errors)
      include Equalizer.new(:errors)
    end
  end
end

require 'rom/rails/model/params'
require 'rom/rails/model/validator'
require 'rom/rails/model/form'
