require 'generators/rom/install_generator'

RSpec.describe ROM::Generators::InstallGenerator, type: :generator do
  destination File.expand_path('../../../tmp', __dir__)

  before(:each) do
    prepare_destination
  end

  it "installs a setup initializer" do
    run_generator ['install']

    expect(destination_root).to have_structure {
      directory 'config' do
        directory 'initializers' do
          file 'rom.rb' do
            contains <<-CONTENT.strip_heredoc
              ROM::Rails::Railtie.configure do |config|
                config.gateways[:default] = [:sql, ENV.fetch('DATABASE_URL')]
              end
            CONTENT
          end
        end
      end
    }
  end

  it "allows overriding the adapter type" do
    run_generator ["install", "--adapter=yaml"]
    initializer = File.read(File.join(destination_root, "config", "initializers", "rom.rb"))

    expect(initializer).to include("config.gateways[:default] = [:yaml, ENV.fetch('DATABASE_URL')]")
  end

  it "sets up lib/types" do
    run_generator ["install"]

    expect(destination_root).to have_structure {
      directory "lib" do
        file "types.rb" do
          contains <<-CONTENT.strip_heredoc
            require "dry/types"

            module Types
              include Dry::Types.module

              ID = Coercible::Int.optional.meta(primary_key: true)

              # Include your own type definitions and coersions here.
              # See http://dry-rb.org/gems/dry-types
            end
          CONTENT
        end
      end
    }
  end

  it "sets up ApplicationModel" do
    run_generator ["install"]

    expect(destination_root).to have_structure {
      directory "app" do
        directory "models" do
          file "application_model.rb" do
            contains <<-CONTENT.strip_heredoc
              require "types"

              class ApplicationModel < ROM::Struct
                def self.inherited(base)
                  super

                  base.constructor_type :schema

                  base.extend ActiveModel::Naming
                  base.include ActiveModel::Conversion

                  base.include Dry::Equalizer(:id)

                  base.attribute :id, Types::ID
                end

                def persisted?
                  id.present?
                end
              end
            CONTENT
          end
        end
      end
    }
  end
end
