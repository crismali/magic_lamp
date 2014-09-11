MagicLamp.register_fixture(name: "custom_name") do
  render "orders/foo"
end

MagicLamp.register_fixture(controller: OrdersController, name: "super_specified") do
  render :foo
end
