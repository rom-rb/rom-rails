require 'active_model'

require 'rom'
require 'rom/rails/version'
require 'rom/rails/railtie'
require 'rom/model'

module ROM
  # Lazy env is set to defer loading whole env during rails booting process
  #
  # This prevents situations where components are defined but db doesn't exist
  # (this can often happen in development)
  #
  # Accessing any of the components using this env will trigger finalization
  # and final env will be set on ROM.env
  #
  # @api private
  class LazyEnv
    attr_reader :rom

    def initialize(rom)
      @rom = rom
    end

    def gateways
      finalize
      env.gateways
    end

    def relation(*args, &block)
      finalize
      env.relation(*args, &block)
    end

    def command(*args, &block)
      finalize
      env.command(*args, &block)
    end

    def mappers
      finalize
      env.mappers
    end

    def finalize
      rom.finalize
    end

    def env
      rom.env
    end
  end

  # Overridden finalize sets up lazy-env first which eventually results in the
  # finalized env on the first access of any components.
  #
  # @api private
  def self.finalize
    if env.is_a?(LazyEnv)
      begin
        @env = @boot.finalize
        self
      ensure
        @boot = nil
      end
    else
      @env = LazyEnv.new(self)
      self
    end
  end
end
