require "rails_helper"

describe MagicLamp do
  context "attr_accessor" do
    it { is_expected.to respond_to :registered_fixtures }
    it { is_expected.to respond_to :registered_fixtures= }

    it { is_expected.to respond_to :configuration }
    it { is_expected.to respond_to :configuration= }
  end

  context "aliases" do
    it { is_expected.to alias_the_method(:register_fixture).to(:register) }
    it { is_expected.to alias_the_method(:register_fixture).to(:fixture) }
    it { is_expected.to alias_the_method(:register_fixture).to(:rub) }
    it { is_expected.to alias_the_method(:register_fixture).to(:wish) }
  end

  describe "#configure" do
    it "yields a configuration object to the block" do
      subject.configure do |config|
        expect(config).to be_a(MagicLamp::Configuration)
      end
    end

    it "replaces its configuration object if called again" do
      subject.configure { |config| config.infer_names = false }
      first_config = subject.configuration
      subject.configure { |config| config.infer_names = false }
      second_config = subject.configuration
      expect(first_config).to_not eq(second_config)
    end

    it "raises an error without a block" do
      expect do
        subject.configure
      end.to raise_error(MagicLamp::ArgumentError, /configure requires a block/)
    end
  end

  context "callbacks with database cleaner" do
    it "keeps the database clean" do
      allow(subject).to receive(:path).and_return(Rails.root.join("persisted_specs"))
      subject.generate_all_fixtures
      expect(Order.count).to eq(0)
    end
  end

  describe "#register_fixture" do
    let(:fixture_name) { "foo" }
    let(:controller_class) { "doesn't matter here" }
    let(:block) { proc { "so?" } }

    it "caches the controller class and block" do
      subject.register_fixture(controller: controller_class, name: fixture_name, &block)
      at_fixture_name = subject.registered_fixtures[fixture_name]
      expect(at_fixture_name[:controller]).to eq(controller_class)
      expect(at_fixture_name[:render_block]).to eq(block)
    end

    it "raises an error without a block" do
      expect do
        subject.register_fixture(controller: controller_class, name: fixture_name)
      end.to raise_error(MagicLamp::ArgumentError, /register_fixture requires a block/)
    end

    context "without name inference" do
      it "raises an error without a specified name" do
        subject.configuration.infer_names = false
        expect do
          subject.register_fixture { render :foo }
        end.to raise_error(MagicLamp::ArgumentError, /You must specify a name since `infer_names` is configured to `false`/)
      end
    end

    context "defaults" do
      let(:at_index) { subject.registered_fixtures["index"] }

      it "uses ApplicationController as the default controller" do
        subject.register_fixture { render :index }
        expect(at_index[:controller]).to eq(::ApplicationController)
      end

      context "extend" do
        it "defaults to an empty array" do
          subject.register_fixture { render :index }
          expect(at_index[:extend]).to eq([])
        end
      end

      context "fixture name" do
        it "raises an error if the fixture is already registered by that name" do
          subject.register_fixture { render :index }
          expect do
            subject.register_fixture { render :index }
          end.to raise_error(MagicLamp::AlreadyRegisteredFixtureError, "a fixture called 'index' has already been registered")
        end

        context "ApplicationController" do
          let(:index) { "index" }

          it "uses the first argument to render when given 2" do
            subject.register_fixture(controller: ::ApplicationController) { render :index, foo: :bar }
            expect(subject.registered_fixtures).to have_key(index)
          end

          it "uses the only argument when it isn't a hash" do
            subject.register_fixture(controller: ::ApplicationController) { render :index }
            expect(subject.registered_fixtures).to have_key(index)
          end

          it "passes its configuration object to the render catcher" do
            expect(MagicLamp::RenderCatcher).to receive(:new).with(subject.configuration).and_call_original
            subject.register_fixture { render :foo }
          end

          context "1 hash argument to render" do
            it "raises an error if it can't figure out a default name" do
              expect do
                subject.register_fixture(controller: ::ApplicationController) { render collection: [1, 2, 3] }
              end.to raise_error(MagicLamp::AmbiguousFixtureNameError, /Unable to infer fixture name/)
            end

            it "uses the name at the template key" do
              subject.register_fixture(controller: ::ApplicationController) { render template: :index }
              expect(subject.registered_fixtures).to have_key(index)
            end

            it "uses the name at the partial key" do
              subject.register_fixture(controller: ::ApplicationController) { render partial: :partial }
              expect(subject.registered_fixtures).to have_key("partial")
            end
          end
        end

        context "other controller" do
          it "prepends the controller's name to the fixture_name" do
            subject.register_fixture(controller: OrdersController) { render partial: :index }
            expect(subject.registered_fixtures).to_not have_key("index")
            expect(subject.registered_fixtures).to have_key("orders/index")
          end

          it "does not prepend the controller's name when it is already the beginning of the string" do
            subject.register_fixture(controller: OrdersController) { render partial: "orders/order" }
            expect(subject.registered_fixtures).to_not have_key("orders/orders/order")
            expect(subject.registered_fixtures).to have_key("orders/order")
          end
        end
      end
    end
  end

  describe "#load_config" do
    it "loads the magic lamp config file" do
      expect(subject).to receive(:registered_fixtures)
      subject.load_config
    end

    it "does not raise an error if there's no config" do
      allow(Dir).to receive(:[]).and_return([])
      expect(subject).to_not receive(:registered_fixtures)
      expect { subject.load_config }.to_not raise_error
    end
  end

  describe "#load_lamp_files" do
    it "loads all lamp files" do
      subject.load_lamp_files
      expect(subject.registered_fixtures["orders/foo"]).to be_a(Hash)
    end

    it "blows out registered_fixtures on each call" do
      old_registry = subject.registered_fixtures
      subject.load_lamp_files
      expect(subject.registered_fixtures).to_not equal(old_registry)

      old_registry = subject.registered_fixtures
      subject.load_lamp_files
      expect(subject.registered_fixtures).to_not equal(old_registry)
    end

    it "loads its config" do
      expect(subject).to receive(:load_config)
      subject.load_lamp_files
    end
  end

  describe "#registered?" do
    it "returns true if the fixture is registered" do
      subject.registered_fixtures["foo"] = :something
      expect(subject.registered?("foo")).to eq(true)
    end

    it "returns false if the fixture is not registered" do
      expect(subject.registered?("bar")).to eq(false)
    end
  end

  describe "#generate_fixture" do
    let(:block) { proc { render :foo } }

    before do
      subject.registered_fixtures["foo_test"] = { controller: OrdersController, render_block: block }
    end

    it "returns the template" do
      expect(subject.generate_fixture("foo_test")).to eq("foo\n")
    end

    it "raises an error when told to generate a template that is not registered" do
      expect do
        subject.generate_fixture("brokenture")
      end.to raise_error(MagicLamp::UnregisteredFixtureError, /is not a registered fixture/)
    end

    it "passes its configuration object to the render catcher" do
      subject.registered_fixtures["foo"] = {}
      dummy = double(generate_template: :generate_template)
      expect(MagicLamp::FixtureCreator).to receive(:new).with(subject.configuration).and_return(dummy)
      subject.generate_fixture("foo")
    end
  end

  describe "#generate_all_fixtures" do
    let!(:result) { subject.generate_all_fixtures }
    let(:foo_fixture) { result["orders/foo"] }
    let(:bar_fixture) { result["orders/bar"] }
    let(:form_fixture) { result["orders/form"] }

    it "returns a hash of all registered fixtures" do
      expect(foo_fixture).to eq("foo\n")
      expect(bar_fixture).to eq("bar\n")
      expect(form_fixture).to match(/<div class="actions"/)
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
