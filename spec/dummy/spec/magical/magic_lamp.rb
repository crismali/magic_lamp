MagicLamp.registered_fixtures[:test] = :fake_registry

MagicLamp.register_fixture do
  render "orders/foo"
end
