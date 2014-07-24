MagicLamp.create_fixture("rake_test", OrdersController) do
  render :foo
end

MagicLamp.register_fixture(OrdersController, "foo_test") do
  render :foo
end
