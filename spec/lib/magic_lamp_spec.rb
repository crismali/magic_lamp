require "rails_helper"

describe MagicLamp do
  before do
    subject.registered_fixtures = {}
  end

  after do
    subject.registered_fixtures = {}
  end

  context "attr_accessor" do
    it { should respond_to :registered_fixtures }
    it { should respond_to :registered_fixtures= }
  end

  describe "#register_fixture" do
    let(:fixture_name) { "foo" }
    let(:controller_class) { "doesn't matter here" }
    let(:block) { Proc.new { "so?" } }

    it "caches the controller class and block" do
      subject.register_fixture(controller_class, fixture_name, &block)
      expect(subject.registered_fixtures[fixture_name]).to eq([controller_class, block])
    end

    it "raises an error without a block" do
      expect do
        subject.register_fixture(controller_class, fixture_name)
      end.to raise_error(/requires a block/)
    end

    context "defaults" do
      it "uses ApplicationController as the default controller" do
        subject.register_fixture { render :index }
        expect(subject.registered_fixtures["index"].first).to eq(::ApplicationController)
      end

      context "fixture name" do
        context "ApplicationController" do
          it "uses the first argument to render when given 2" do
            render_block = Proc.new { render :index, foo: :bar }
            subject.register_fixture(::ApplicationController, &render_block)

            expect(subject.registered_fixtures["index"]).to eq([::ApplicationController, render_block])
          end

          it "uses the only argument when it isn't a hash" do
            render_block = Proc.new { render :index }
            subject.register_fixture(::ApplicationController, &render_block)
            expect(subject.registered_fixtures["index"]).to eq([::ApplicationController, render_block])
          end

          context "1 hash argument" do
            it "raises an error if it can't figure out a default name" do
              expect do
                subject.register_fixture(::ApplicationController) { render collection: [1, 2, 3] }
              end.to raise_error(/Unable to infer fixture name/)
            end

            it "uses the name at the template key" do
              render_block = Proc.new { render template: :index }
              subject.register_fixture(::ApplicationController, &render_block)
              expect(subject.registered_fixtures["index"]).to eq([::ApplicationController, render_block])
            end

            it "uses the name at the partial key" do
              render_block = Proc.new { render partial: :index }
              subject.register_fixture(::ApplicationController, &render_block)
              expect(subject.registered_fixtures["index"]).to eq([::ApplicationController, render_block])
            end
          end
        end

        context "other controller" do
          it "prepends the controller's name to the fixture_name" do
            render_block = Proc.new { render partial: :index }
            subject.register_fixture(OrdersController, &render_block)
            expect(subject.registered_fixtures["orders/index"]).to eq([OrdersController, render_block])
          end
        end
      end
    end
  end

  describe "#load_lamp_files" do
    it "loads all lamp files" do
      subject.load_lamp_files
      expect(subject.registered_fixtures[:test]).to eq(:fake_registry)
    end

    it "blows out registered_fixtures on each call" do
      old_registry = subject.registered_fixtures
      subject.load_lamp_files
      expect(subject.registered_fixtures).to_not equal(old_registry)

      old_registry = subject.registered_fixtures
      subject.load_lamp_files
      expect(subject.registered_fixtures).to_not equal(old_registry)
    end
  end

  describe "#generate_fixture" do
    let(:block) { Proc.new { render :foo } }

    before do
      subject.registered_fixtures["foo_test"] = [OrdersController, block]
    end

    it "returns the template" do
      expect(subject.generate_fixture("foo_test")).to eq("foo\n")
    end

    it "raises an error when told to generate a template that is not registered" do
      expect do
        subject.generate_fixture("brokenture")
      end.to raise_error(/is not a registered fixture/)
    end
  end

  describe "#path" do
    context "spec directory" do
      let(:spec_path) { Rails.root.join("spec") }

      it "returns a default path starting from spec" do
        expect(subject.path).to eq(spec_path)
      end
    end

    context "no spec directory" do
      let(:test_path) { Rails.root.join("test") }

      it "returns a default path starting from test" do
        allow(Dir).to receive(:exist?).and_return(false)
        expect(subject.path).to eq(test_path)
      end
    end
  end
end
