MagicLamp.register_fixture do
  @order = Order.create!(name: "bar")
  render partial: "orders/form"
end

MagicLamp.register_fixture do
  extend AuthenticationStub
  @apples = 3.times.map { Apple.create! }
  render "apples/index"
end
