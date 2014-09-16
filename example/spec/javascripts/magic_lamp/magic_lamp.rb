MagicLamp.register_fixture do
  @order = Order.create!(name: "bar")
  render partial: "orders/form"
end
