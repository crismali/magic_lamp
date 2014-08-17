require "rails_helper"

module MagicLamp
  describe FixturesController do
    shared_examples "it handles errors" do
      before do
        allow(MagicLamp).to receive(:generate_fixture).and_raise(error, "message")
      end

      it "outputs the error and the message to the server log" do
        expect(controller.logger).to receive(:error) do |error_message|
          expect(error_message).to match(/message\n\s\s\s\s.*magic_lamp\//m)
        end
        get :show, name: "orders/baz", use_route: :magic_lamp
      end

      it "renders the error as text for the client side" do
        get :show, name: "orders/baz", use_route: :magic_lamp
        expect(response.body).to eq("message")
      end

      it "renders a 500" do
        get :show, name: "orders/baz", use_route: :magic_lamp
        expect(response.status).to eq(500)
      end
    end

    context "ArgumentError" do
      it_behaves_like "it handles errors" do
        let(:error) { ArgumentError }
      end
    end

    context "AlreadyRegisteredFixtureError" do
      it_behaves_like "it handles errors" do
        let(:error) { AlreadyRegisteredFixtureError }
      end
    end

    context "AmbiguousFixtureNameError" do
      it_behaves_like "it handles errors" do
        let(:error) { AmbiguousFixtureNameError }
      end
    end

    context "UnregisteredFixtureError" do
      it_behaves_like "it handles errors" do
        let(:error) { UnregisteredFixtureError }
      end
    end

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
      let(:form_fixture) { parsed_response["orders/form"] }

      it "returns a json hash of all registered fixtures" do
        get :index, use_route: :magic_lamp
        expect(foo_fixture).to eq("foo\n")
        expect(bar_fixture).to eq("bar\n")
        expect(form_fixture).to match(/<div class="actions"/)
      end
    end
  end
end
