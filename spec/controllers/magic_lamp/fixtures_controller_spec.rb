require "rails_helper"

module MagicLamp
  describe FixturesController do
    describe "#show" do
      it "renders the specified template" do
        get :show, name: "orders/foo", use_route: :magic_lamp
        expect(response.body).to eq("foo\n")
      end
    end

    describe "#index" do
      let(:parsed_response) { JSON.parse(response.body) }
      let(:foo_fixture) { parsed_response["orders/foo"] }
      let(:bar_fixture) { parsed_response["orders/bar"] }

      it "returns a json hash of all registered fixtures" do
        get :index, use_route: :magic_lamp
        expect(foo_fixture).to eq("foo\n")
        expect(bar_fixture).to eq("bar\n")
      end
    end
  end
end
