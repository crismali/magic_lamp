MagicLamp.register_fixture do
  render "orders/foo"
end

MagicLamp.register_fixture(controller: OrdersController) do
  render "orders/bar"
end

MagicLamp.register_fixture do
  @order = Order.new
  render partial: "orders/form"
end

MagicLamp.fixture(name: "hash_to_jsoned") do
  { foo: "bar" }
end

MagicLamp.fixture(name: "just_some_string") do
  "I'm a super awesome string"
end
