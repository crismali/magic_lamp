require "rails_helper"

describe MagicLamp::FixtureCreator do
  context "attr_accessor" do
    context "render_arguments" do
      it { is_expected.to respond_to :render_arguments }
      it { is_expected.to respond_to :render_arguments= }
    end

    context "namespace" do
      it { is_expected.to respond_to :namespace }
      it { is_expected.to respond_to :namespace= }
    end
  end

  describe "#initialize" do
    it "sets MagicLamp as namespace" do
      expect(subject.namespace).to eq(MagicLamp)
    end
  end

  describe "#generate_template" do
    let(:rendered) do
      subject.generate_template(OrdersController) do
        render :foo
      end
    end

    it "returns the template as a string" do
      expect(rendered).to eq("foo\n")
    end

    it "does not render the layout by default" do
      expect(rendered).to_not match(/The layout/)
    end
  end

  describe "#new_controller" do

    it "returns an instance of the passed controller class" do
      expect(subject.new_controller(OrdersController) {} ).to be_a(OrdersController)
    end

    context "contoller" do
      let(:controller) { subject.new_controller(OrdersController) { params[:foo] = "bar" } }

      it "can have render_to_string called on it without blowing up" do
        expect do
          controller.render_to_string :foo
        end.to_not raise_error
      end

      it "has had its state set by the given block" do
        expect(controller.params[:foo]).to eq("bar")
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
