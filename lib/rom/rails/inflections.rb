require 'active_support/inflections'

ActiveSupport::Inflector.inflections do |inflect|
  # `acronym` was added in ActiveSupport 3.2.5
  inflect.acronym 'ROM' if inflect.respond_to?(:acronym)
end
