MagicLamp.register_fixture(name: "custom_name") do
  render "orders/foo"
end

MagicLamp.register_fixture(controller: OrdersController, name: "super_specified") do
  render :foo
end

module AuthStub
  def current_user_name
    "Stevenson"
  end
end

MagicLamp.define(extend: AuthStub) do |genie|
  genie.fixture do
    current_user_name # called here to make sure we can call it here
    render "orders/needs_extending"
  end
end
