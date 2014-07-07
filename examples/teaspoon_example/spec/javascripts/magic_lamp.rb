# This file could be named anything as long as it ended with "_lamp.rb"
# It could also be anywhere under "spec" or "test "
MagicLamp.create_fixture("foo", OrdersController) do
  render :index
end
