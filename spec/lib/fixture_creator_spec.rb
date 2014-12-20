require "rails_helper"

describe MagicLamp::FixtureCreator do
  subject { MagicLamp::FixtureCreator.new(MagicLamp::Configuration.new) }

  it { is_expected.to be_kind_of(MagicLamp::Callbacks) }

  context "attr_accessor" do
    it { is_expected.to attr_accessorize :render_arguments }
  end

  describe "#generate_template" do
    context "render called" do
      let(:rendered) do
        subject.generate_template(OrdersController, []) do
          render :foo
        end
      end

      it "returns the template as a string" do
        expect(rendered).to eq("foo\n")
      end

      it "does not render the layout by default" do
        expect(rendered).to_not match(/The layout/)
      end

      it "executes the callbacks around generation of the template" do
        dummy = double
        expect(subject).to receive(:execute_before_each_callback).ordered
        expect(dummy).to receive(:render).ordered
        expect(subject).to receive(:execute_after_each_callback).ordered
        subject.generate_template(OrdersController, []) do
          dummy.render
          render :foo
        end
      end

      context "render json (non string)" do
        let!(:rendered) do
          subject.generate_template(OrdersController, []) do
            render json: { foo: :bar }
          end
        end

        it "renders json passed to render" do
          expect(rendered).to eq({ foo: :bar }.to_json)
        end
      end

      context "render json (string)" do
        let!(:rendered) do
          subject.generate_template(OrdersController, []) do
            render json: "woohoo!"
          end
        end

        it "renders json passed to render" do
          expect(rendered).to eq("woohoo!")
        end
      end
    end

    context "render not called" do
      context "render block returns a string" do
        let(:rendered) do
          subject.generate_template(OrdersController, []) do
            { foo: "bar" }.to_json
          end
        end

        it "returns the string" do
          expect(rendered).to eq({ foo: "bar" }.to_json)
        end
      end

      context "render block returns someting else" do
        let(:rendered) do
          subject.generate_template(OrdersController, []) do
            { foo: "bar" }
          end
        end

        it "returns the #to_json representation of the object" do
          expect(rendered).to eq({ foo: "bar" }.to_json)
        end
      end
    end
  end

  describe "#new_controller" do
    it "returns an instance of the passed controller class" do
      expect(subject.new_controller(OrdersController, []) {}).to be_a(OrdersController)
    end

    context "contoller" do
      module Foo
        def foo_module_method
        end
      end

      module Bar
        def bar_module_method
        end
      end

      let(:controller) { subject.new_controller(OrdersController, [Foo, Bar]) { params[:foo] = "bar" } }

      it "can have render_to_string called on it without blowing up" do
        expect do
          controller.render_to_string :foo
        end.to_not raise_error
      end

      it "has been extended with the extensions" do
        expect(controller.class.ancestors).to_not include(Foo)
        expect(controller.class.ancestors).to_not include(Bar)
        expect(controller).to respond_to(:foo_module_method)
        expect(controller).to respond_to(:bar_module_method)
      end

      context "view_context" do
        it "has the extensions mixed into it" do
          expect(controller.view_context.class.ancestors).to_not include(Foo)
          expect(controller.view_context.class.ancestors).to_not include(Bar)
          expect(controller.view_context).to respond_to(:foo_module_method)
          expect(controller.view_context).to respond_to(:bar_module_method)
        end
      end

      context "stubbed controller#render" do
        it "passes its arguments to the fixture creator at render arguments" do
          controller.render :foo, :bar
          expect(subject.render_arguments).to eq([:foo, :bar])
        end
      end
    end
  end

  describe "#munge_arguments" do
    context "no options" do
      let(:munged_arguments) { subject.munge_arguments([:foo]) }
      let(:options) { munged_arguments.last }

      it "provides a hash as the final argument if there isn't one already" do
        expect(options).to be_a(Hash)
      end

      it "sets layout to false" do
        expect(options[:layout]).to eq(false)
      end

      it "preserves the first argument" do
        expect(munged_arguments.size).to eq(2)
        expect(munged_arguments.first).to eq(:foo)
      end
    end

    context "with options" do
      let(:munged_arguments) { subject.munge_arguments([:foo, some_option: true]) }
      let(:options) { munged_arguments.last }

      it "preserves the other options" do
        expect(options[:some_option]).to eq(true)
      end

      it "sets layout to false" do
        expect(options[:layout]).to eq(false)
      end

      it "preserves the first argument" do
        expect(munged_arguments.first).to eq(:foo)
      end

      context "layout specified" do
        let(:munged_arguments) { subject.munge_arguments([:foo, layout: "bar"]) }

        it "preserves the layout value" do
          expect(options[:layout]).to eq("bar")
        end
      end
    end

    context "only options" do
      let(:munged_arguments) { subject.munge_arguments([partial: "foo"]) }
      let(:options) { munged_arguments.first }

      it "preserves the other options" do
        expect(options[:partial]).to eq("foo")
      end

      it "sets layout to false" do
        expect(options[:layout]).to eq(false)
      end

      context "layout specified" do
        let(:munged_arguments) { subject.munge_arguments([partial: "foo", layout: "bar"]) }

        it "preserves the layout value" do
          expect(options[:layout]).to eq("bar")
        end
      end
    end
  end
end
