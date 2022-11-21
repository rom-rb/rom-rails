module NamespacedApp
  module Persistence
    module Commands
      class CreateAdditionalTask < ROM::Commands::Create[:sql]
        relation :tasks
        register_as :namespaced_additional
        result :one
      end
    end
  end
end