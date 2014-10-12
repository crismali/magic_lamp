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

MagicLamp.define(controller: OrdersController) do |genie|
  genie.define(namespace: :errors) do |errors_genie|
    errors_genie.define do |nested_errors_genie|
      nested_errors_genie.define(namespace: "foos") do |foos_genie|
        foos_genie.define do |deeply_nested_genie|
          deeply_nested_genie.fixture(controller: OrdersController, namespace: :bar, name: :baz) do
            render :foo
          end
        end
      end
    end
  end
end
