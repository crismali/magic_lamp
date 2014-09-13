# Don't pass name argument here for the sake of the db cleaner spec
MagicLamp.register_fixture do
  @order = Order.create!
  render partial: "orders/form"
end
