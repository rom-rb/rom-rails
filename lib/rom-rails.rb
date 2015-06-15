require 'active_model'

require 'rom'
require 'rom/rails/version'
require 'rom/rails/railtie'
require 'rom/model'

module ROM
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

    def finalize
      rom.finalize
    end

    def env
      rom.env
    end
  end

  def self.finalize
    if env.is_a?(LazyEnv)
      begin
        @env = @boot.finalize
      ensure
        @boot = nil
      end
    else
      @env = LazyEnv.new(self)
    end
  end
end
