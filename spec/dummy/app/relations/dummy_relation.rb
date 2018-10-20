class DummyRelation < ROM::Relation[:test_adapter]
  gateway :default

  schema(:dummy, infer: true)
end
