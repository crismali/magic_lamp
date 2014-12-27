MagicLamp.fixture(name: "foo") do
  raise "first fixture"
  render :foo
end

MagicLamp.define(controller: OrdersController) do
  fixture(name: :bar) do
    raise "second fixture"
    render :foo
  end
end

MagicLamp.fixture(name: "okay") do
  {}
end
