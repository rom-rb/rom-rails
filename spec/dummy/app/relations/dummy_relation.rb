class DummyRelation < ROM::Relation[:test_adapter]
  register_as :dummy
  repository :test
end
