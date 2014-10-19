MagicLamp.define do
  fixture do
    @order = Order.create!(name: "bar")
    render partial: "orders/form"
  end

  fixture(extend: AuthenticationStub) do
    @apples = 3.times.map { Apple.create! }
    render "apples/index"
  end
end
