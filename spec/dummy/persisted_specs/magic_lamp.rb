MagicLamp.register_fixture do
  @order = Order.create!
  render partial: "orders/form"
end
