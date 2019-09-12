require "dry/types"

module Types
  include Dry.Types

  ID = Coercible::Integer.optional.meta(primary_key: true)

  # Include your own type definitions and coersions here.
  # See http://dry-rb.org/gems/dry-types
end
