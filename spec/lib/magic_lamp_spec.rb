# frozen_string_literal: true

require "rails_helper"

describe MagicLamp do
  context "attr_accessor" do
    it { is_expected.to attr_accessorize(:registered_fixtures) }
    it { is_expected.to attr_accessorize(:configuration) }
  end

  context "aliases" do
    MagicLamp::REGISTER_FIXTURE_ALIASES.each do |method_name|
      it { is_expected.to alias_the_method(:register_fixture).to(method_name) }
    end
  end

  describe "#define" do
    let(:block) { proc { "foo" } }
    let(:options) { { foo: :bar } }

    it "creates a new defaults manager and evaluates the block in its context" do
      suspect = subject.define(options) do |block_arg|
        @foo = "foo"
      end
      expect(suspect).to be_a(MagicLamp::DefaultsManager)
      expect(suspect.instance_variable_get(:@foo)).to eq("foo")
      expect(suspect.configuration).to eq(subject.configuration)
      expect(suspect.defaults).to eq(options)
      expect(suspect.parent).to be_nil
    end

    it "raises an error if it's not given a block" do
      expect do
        subject.define
      end.to raise_error(MagicLamp::ArgumentError, /define requires a block/)
    end
  end

  describe "#configure" do
    it "yields a configuration object to the block" do
      subject.configure do |config|
        expect(config).to be_a(MagicLamp::Configuration)
      end
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
    let(:controller_class) { ::ApplicationController }
    let(:block) { proc { "so?" } }
    let(:extensions) { [1, 2, 3] }

    it "caches the controller class, block, and extensions" do
      subject.register_fixture(controller: controller_class, name: fixture_name, extend: extensions, &block)
      at_fixture_name = subject.registered_fixtures[fixture_name]
      expect(at_fixture_name[:controller]).to eq(controller_class)
      expect(at_fixture_name[:render_block]).to eq(block)
      expect(at_fixture_name[:extend]).to eq(extensions)
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

        it "wraps a bare object in an array" do
          subject.register_fixture(extend: "foo") { render :index }
          expect(at_index[:extend]).to eq(["foo"])
        end

        it "does not double wrap an array" do
          subject.register_fixture(extend: ["foo"]) { render :index }
          expect(at_index[:extend]).to eq(["foo"])
        end
      end

      context "fixture name" do
        it "raises an error if the fixture is already registered by that name" do
          subject.register_fixture { render :index }
          expect do
            subject.register_fixture { render :index }
          end.to raise_error(MagicLamp::AlreadyRegisteredFixtureError, "a fixture called 'index' has already been registered")
        end

        context "namespacing" do
          it "removes 'application'" do
            subject.register_fixture(namespace: "application/orders/application/foos") { render :foo }
            expect(subject.registered_fixtures).to_not have_key("application/orders/application/foos/foo")
            expect(subject.registered_fixtures).to have_key("orders/foos/foo")
          end

          it "prevents double namespacing" do
            subject.register_fixture(namespace: "orders/orders/foos/orders/orders/bars") { render :foo }
            expect(subject.registered_fixtures).to_not have_key("orders/orders/foos/orders/orders/bars/foo")
            expect(subject.registered_fixtures).to have_key("orders/foos/orders/bars/foo")
          end
        end

        context "with ApplicationController" do
          let(:index) { "index" }

          it "is the first argument to render when given 2" do
            subject.register_fixture(controller: ::ApplicationController) { render :index, foo: :bar }
            expect(subject.registered_fixtures).to have_key(index)
          end

          it "is the only argument when it isn't a hash" do
            subject.register_fixture(controller: ::ApplicationController) { render :index }
            expect(subject.registered_fixtures).to have_key(index)
          end

          it "passes its configuration object to the render catcher" do
            expect(MagicLamp::RenderCatcher).to receive(:new).with(subject.configuration).and_call_original
            subject.register_fixture { render :foo }
          end

          context "and 1 hash argument to render" do
            it "raises an error if it can't figure out a default name" do
              expect do
                subject.register_fixture(controller: ::ApplicationController) { render collection: [1, 2, 3] }
              end.to raise_error(MagicLamp::AmbiguousFixtureNameError, /Unable to infer fixture name/)
            end

            it "is the name at the template key" do
              subject.register_fixture(controller: ::ApplicationController) { render template: :index }
              expect(subject.registered_fixtures).to have_key(index)
            end

            it "is the name at the partial key" do
              subject.register_fixture(controller: ::ApplicationController) { render partial: :partial }
              expect(subject.registered_fixtures).to have_key("partial")
            end
          end

          context "namespacing" do
            it "prepends the namespace to the front of the fixture name when inferred" do
              subject.register_fixture(controller: ::ApplicationController, namespace: "foo") do
                render :bar
              end
              expect(subject.registered_fixtures).to have_key("foo/bar")
            end

            it "prepends the namespace to the front of the fixture name when specified" do
              subject.register_fixture(controller: ::ApplicationController, namespace: "foo", name: "baz") do
                render :bar
              end
              expect(subject.registered_fixtures).to have_key("foo/baz")
            end
          end
        end

        context "with another controller" do
          context "namespacing" do
            context "unspecified namespace" do
              it "namespaces the fixture name with the controller's name" do
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

            context "specified namespace" do
              it "does not use the controller's name as a namespace" do
                subject.register_fixture(controller: OrdersController, namespace: "foo") { render partial: :index }
                expect(subject.registered_fixtures).to_not have_key("orders/index")
                expect(subject.registered_fixtures).to have_key("foo/index")
              end

              it "does not prepend the namespace when the fixture name starts with the string" do
                subject.register_fixture(controller: OrdersController, namespace: "foo") { render partial: "foo/order" }
                expect(subject.registered_fixtures).to_not have_key("foo/foo/order")
                expect(subject.registered_fixtures).to have_key("foo/order")
              end
            end
          end
        end
      end
    end
  end

  describe "#load_config" do
    it "sets configuration to a new configuration object" do
      old_config = subject.configuration
      subject.load_config
      expect(subject.configuration).to_not equal(old_config)
    end

    it "loads the magic lamp config file from the spec and test directories" do
      expect(subject).to receive(:registered?).with("spec")
      expect(subject).to receive(:registered?).with("test")
      subject.load_config
    end

    it "does not raise an error if there's no config" do
      allow(Dir).to receive(:[]).and_return([])
      expect(subject).to_not receive(:registered_fixtures)
      expect { subject.load_config }.to_not raise_error
    end

    context "FactoryGirl is not defined" do
      before do
        hide_const "FactoryGirl"
      end

      it "does not raise an error" do
        expect { subject.load_config }.to_not raise_error
      end
    end

    context "FactoryGirl is defined" do
      let(:spy) { double }

      before do
        stub_const "FactoryGirl", spy
      end

      it "calls reload on FactoryGirl" do
        expect(spy).to receive(:reload)
        subject.load_config
      end
    end
  end

  describe "#load_lamp_files" do
    it "loads all lamp files from the spec directory" do
      subject.load_lamp_files
      expect(subject.registered_fixtures["orders/foo"]).to be_a(Hash)
    end

    it "loads all lamp files from the test directory" do
      subject.load_lamp_files
      expect(subject.registered_fixtures["from_test_directory"]).to be_a(Hash)
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
    let(:fixture_name) { "foo_test" }
    let(:extensions) { Array.new(3) { Module.new } }

    before do
      subject.registered_fixtures[fixture_name] = {
        controller: OrdersController,
        render_block: block,
        extend: extensions
      }
    end

    it "returns the template" do
      expect(subject.generate_fixture(fixture_name)).to eq("foo\n")
    end

    it "raises an error when told to generate a template that is not registered" do
      expect do
        subject.generate_fixture("brokenture")
      end.to raise_error(MagicLamp::UnregisteredFixtureError, /is not a registered fixture/)
    end

    it "passes its configuration object to the fixture creator" do
      dummy = double(generate_template: :generate_template)
      expect(MagicLamp::FixtureCreator).to receive(:new).with(subject.configuration).and_return(dummy)
      subject.generate_fixture(fixture_name)
    end

    it "passes the controller, extensions, and block to the fixture creator's generate_template method" do
      dummy = double
      allow(MagicLamp::FixtureCreator).to receive(:new).and_return(dummy)
      expect(dummy).to receive(:generate_template) do |controller, extend_args, &passed_block|
        expect(controller).to eq(OrdersController)
        expect(extend_args).to eq(extensions)
        expect(passed_block).to eq(block)
      end
      subject.generate_fixture(fixture_name)
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

  describe "#lint_config" do
    it "sets registered fixtures to an empty hash" do
      subject.registered_fixtures = { foo: "bar" }
      subject.lint_config
      expect(subject.registered_fixtures).to eq({})
    end

    context "no errors" do
      it "returns an empty hash" do
        expect(subject.lint_config).to eq({})
      end
    end

    context "config file load error" do
      it "returns a hash with the specified error" do
        allow(subject).to receive(:load_config) do
          load Rails.root.join("error_specs", "config_file_load_error.rb")
        end
        result = subject.lint_config
        expect(result).to have_key(:config_file_load)
        expect(result[:config_file_load]).to match(/RuntimeError: Nope\n\s\s\s\s.+\.rb/)
      end
    end

    context "callbacks" do
      let!(:error_proc) { proc { raise "Nope" } }

      %i[before after].each do |callback_type|
        it "returns a hash that with the errored #{callback_type} callback information" do
          expect_any_instance_of(MagicLamp::Configuration).to receive("#{callback_type}_each_proc").and_return(error_proc)
          result = subject.lint_config
          expect(result).to have_key("#{callback_type}_each".to_sym)
          expect(result["#{callback_type}_each".to_sym]).to match(/RuntimeError: Nope\n\s\s\s\s.+\.rb/)
        end
      end
    end
  end

  describe "#lint_fixtures" do
    it "clears registered fixtures" do
      subject.registered_fixtures[:foo] = :bar
      subject.lint_fixtures
      expect(subject.registered_fixtures).to_not have_key(:foo)
    end

    context "no errors" do
      it "returns an hash with empty hashes" do
        expect(subject.lint_fixtures).to eq(fixtures: {}, files: {})
      end
    end

    context "loading lamp files errors" do
      it "returns a hash where the keys are file paths (and line number) and the values are the errors" do
        lamp_file_paths = ["first_errored_lamp_file.rb", "second_errored_lamp_file.rb"].map do |file_name|
          Rails.root.join("error_specs", file_name).to_s
        end
        first_error_file_path, second_error_file_path = lamp_file_paths
        allow(subject).to receive(:lamp_files).and_return(lamp_file_paths)

        result = subject.lint_fixtures[:files]
        expect(result).to have_key(first_error_file_path)
        expect(result).to have_key(second_error_file_path)

        expect(result[first_error_file_path]).to match(/RuntimeError: first file/)
        expect(result[second_error_file_path]).to match(/RuntimeError: second file/)
      end
    end

    context "rendering fixture errors" do
      it "returns a hash where the fixture names are the keys and the values are what's in registered fixtures" do
        allow(subject).to receive(:lamp_files).and_return([Rails.root.join("error_specs", "broken_fixtures.rb").to_s])
        result = subject.lint_fixtures[:fixtures]

        expect(result.keys).to match_array(["foo", "orders/bar"])

        foo_result = result["foo"]
        bar_result = result["orders/bar"]

        %i[render_block extend controller].each do |key|
          expect(foo_result[key]).to eq(subject.registered_fixtures["foo"][key])
          expect(bar_result[key]).to eq(subject.registered_fixtures["orders/bar"][key])
        end

        expect(foo_result[:error]).to match(/RuntimeError: first fixture/)
        expect(bar_result[:error]).to match(/RuntimeError: second fixture/)
      end
    end
  end
end
