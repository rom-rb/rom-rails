require "types"
require "dry/core/equalizer"

class ApplicationModel < ROM::Struct
  def self.inherited(base)
    super

    base.transform_types(&:omittable)

    base.extend ActiveModel::Naming
    base.include ActiveModel::Conversion

    base.include Dry::Core::Equalizer.new(:id)

    base.attribute :id, Types::ID
  end

  def persisted?
    id.present?
  end
end
