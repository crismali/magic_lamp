require "rails_helper"

module MagicLamp
  describe FixturesController do
    describe "#show" do
      it "renders the specified template" do
        get :show, name: "orders/foo", use_route: :magic_lamp
        expect(response.body).to eq("foo\n")
      end
    end
  end
end
