MagicLamp.register_fixture do
  @thing = Thing.new(id: 5)
  render "things/show"
end
