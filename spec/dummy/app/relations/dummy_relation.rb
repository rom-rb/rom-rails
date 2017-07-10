class DummyRelation < ROM::Relation[:test_adapter]
  gateway :test

  schema(:dummy, infer: true)
end
