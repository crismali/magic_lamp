require "rails_helper"

module MagicLamp
  describe TestController do

    describe "#index" do

      it "works" do
        get :index, use_route: :magic_lamp
        expect(response.body).to eq("foo")
      end
    end
  end
end
