require "types"

class ApplicationModel < ROM::Struct
  def self.inherited(base)
    super

    base.transform_types(&:omittable)

    base.extend ActiveModel::Naming
    base.include ActiveModel::Conversion

    base.include Dry::Equalizer(:id)

    base.attribute :id, Types::ID
  end

  def persisted?
    id.present?
  end
end
