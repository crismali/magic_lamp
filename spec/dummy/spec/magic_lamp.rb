MagicLamp.create_fixture("via_magic_lamp_file", OrdersController) do
  @order = Order.new
  render :new
end
