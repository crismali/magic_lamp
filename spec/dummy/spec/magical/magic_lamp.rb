MagicLamp.register_fixture do
  render "orders/foo"
end

MagicLamp.register_fixture do
  render "orders/bar"
end

MagicLamp.register_fixture do
  @order = Order.new
  render partial: "orders/form"
end
