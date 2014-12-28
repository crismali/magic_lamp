module SomeExtension
end

module OtherExtension
end

MagicLamp.fixture(name: "foo") do
  raise "first fixture"
  render :foo
end

MagicLamp.define(controller: OrdersController, extend: SomeExtension) do
  fixture(name: :bar, extend: OtherExtension) do
    raise "second fixture"
    render :foo
  end
end

MagicLamp.fixture(name: "okay") do
  {}
end
