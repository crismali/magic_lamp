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

module AdminStub
  def current_admin_name
    "Paulson"
  end
end

module OtherAdminStub
  def current_admin_name
    "Peterson"
  end
end

MagicLamp.define(extend: [AuthStub, AdminStub]) do
  fixture do
    current_user_name # called here to make sure we can call it here
    render "orders/needs_extending"
  end
end

MagicLamp.define do
  define(namespace: "arbitrary") do
    define(extend: [AuthStub, AdminStub]) do
      define(controller: OrdersController) do
        define(extend: OtherAdminStub) do
          fixture(name: "other_admin_extending") do
            render :needs_extending
          end

          fixture(name: "admin_extending", extend: AdminStub) do
            render :needs_extending
          end
        end
      end
    end
  end
end

MagicLamp.define(controller: OrdersController) do
  define(namespace: :errors) do
    define do
      define(namespace: "foos") do
        define do
          fixture(controller: OrdersController, namespace: :bar, name: :baz) do
            render :foo
          end
        end
      end
    end
  end
end
