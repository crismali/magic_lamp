MagicLamp.registered_fixtures[:test] = :fake_registry

MagicLamp.register_fixture(OrdersController, "index") do
  @orders = 3.times.map { |i| Order.new(id: i + 1) }
  render :index
end
