require "rails_helper"

describe MagicLamp::DefaultsManager do
  subject { MagicLamp::DefaultsManager.new(MagicLamp::Configuration.new, {}) }

  context "attr_accessor" do
    it { is_expected.to attr_accessorize(:configuration) }
    it { is_expected.to attr_accessorize(:parent) }
    it { is_expected.to attr_accessorize(:defaults) }
  end

  context "aliases" do
    MagicLamp::REGISTER_FIXTURE_ALIASES.each do |method_name|
      it { is_expected.to alias_the_method(:register_fixture).to(method_name) }
    end
  end

  describe "#initialize" do
    let(:configuration) { double }
    let(:defaults) { double }
    let(:parent) { double }

    it "sets configuration to the given argument" do
      subject = MagicLamp::DefaultsManager.new(configuration, {})
      expect(subject.configuration).to eq(configuration)
    end

    it "sets defaults" do
      subject = MagicLamp::DefaultsManager.new(configuration, defaults)
      expect(subject.defaults).to eq(defaults)
    end

    it "defaults parent to nil" do
      expect(subject.parent).to be_nil
    end

    it "sets parent when given" do
      subject = MagicLamp::DefaultsManager.new(configuration, {}, parent)
      expect(subject.parent).to eq(parent)
    end
  end

  describe "#branch" do
    let(:configuration) { MagicLamp::Configuration.new }
    let(:great_grandparent) { MagicLamp::DefaultsManager.new(configuration, {}) }
    let(:grandparent) { MagicLamp::DefaultsManager.new(configuration, {}, great_grandparent) }
    let(:parent) { MagicLamp::DefaultsManager.new(configuration, {}, grandparent) }
    subject { MagicLamp::DefaultsManager.new(configuration, {}, parent) }
    let(:actual) { subject.branch }
    let(:branch) { [great_grandparent, grandparent, parent, subject] }

    it "returns all of the manager's parents and itself in hierarchical order" do
      expect(actual).to match_array(branch)
      expect(actual).to eq(branch)
    end
  end

  describe "#all_defaults" do
    let(:global_defaults) { { global: :defaults } }
    let(:grandparent_defaults) { { grandparent: :defaults } }
    let(:parent_defaults) { { parent: :defaults } }
    let(:subject_defaults) { { subject: :defaults } }
    let(:configuration) { MagicLamp::Configuration.new.tap { |config| config.global_defaults = global_defaults } }
    let(:grandparent) { MagicLamp::DefaultsManager.new(configuration, grandparent_defaults) }
    let(:parent) { MagicLamp::DefaultsManager.new(configuration, parent_defaults, grandparent) }
    let(:passed_in_defaults) { { passed: :in } }
    subject { MagicLamp::DefaultsManager.new(configuration, subject_defaults, parent) }
    let(:actual) { subject.all_defaults(passed_in_defaults) }
    let(:expected_defaults) { [global_defaults, grandparent_defaults, parent_defaults, subject_defaults, passed_in_defaults] }

    it "returns the global defaults, all parent defaults, the manager's defaults, and the passed in defaults" do
      expect(actual).to match_array(expected_defaults)
      expect(actual).to eq(expected_defaults)
    end
  end

  describe "#merge_with_defaults" do
    let(:extension) { Module.new }
    let(:other_extension) { Module.new }
    let(:global_defaults) { { global: :defaults, namespace: :global } }
    let(:grandparent_defaults) { { grandparent: :defaults, that: :is_ignored, namespace: "", extend: [extension] } }
    let(:parent_defaults) { { parent: :defaults, this: :is_ignored, controller: OrdersController, extend: other_extension } }
    let(:subject_defaults) { { subject: :defaults, this: :is_there, namespace: :subject } }
    let(:configuration) { MagicLamp::Configuration.new.tap { |config| config.global_defaults = global_defaults } }
    let(:grandparent) { MagicLamp::DefaultsManager.new(configuration, grandparent_defaults) }
    let(:parent) { MagicLamp::DefaultsManager.new(configuration, parent_defaults, grandparent) }
    subject { MagicLamp::DefaultsManager.new(configuration, subject_defaults, parent) }
    let(:actual) { subject.merge_with_defaults(that: :is_there, namespace: :passed, controller: OrdersController) }
    let(:expected_defaults) do
      {
        controller: OrdersController,
        global: :defaults,
        grandparent: :defaults,
        parent: :defaults,
        subject: :defaults,
        this: :is_there,
        that: :is_there,
        namespace: "global/orders/subject/passed",
        extend: [extension, other_extension]
      }
    end

    it "merges all of the branch's defaults into one hash where the children take precedence" do
      expect(actual).to eq(expected_defaults)
    end
  end

  describe "#define" do
    let(:new_defaults) { { very_new: :defaults } }

    it "creates a new defaults manager and evaluates the block in its context" do
      suspect = subject.define(new_defaults) do
        @foo = "foo"
      end
      expect(suspect).to be_a(MagicLamp::DefaultsManager)
      expect(suspect).to_not eq(subject)
      expect(suspect.instance_variable_get(:@foo)).to eq("foo")
      expect(suspect.defaults).to eq(new_defaults)
      expect(suspect.configuration).to eq(subject.configuration)
      expect(suspect.parent).to eq(subject)
    end

    it "does not require a defaults hash argument" do
      expect { subject.define {} }.to_not raise_error
    end

    it "raises an error if called without a block" do
      expect do
        subject.define(foo: :bar)
      end.to raise_error(MagicLamp::ArgumentError, "`define` requires a block")
    end
  end

  describe "#register_fixture" do
    context "calling MagicLamp.register_fixture" do
      let(:configuration) { MagicLamp::Configuration.new }
      let(:block) { proc { "foo" } }
      let(:given_options) { { this: :is_there } }
      let(:parent_defaults) { { parent: :defaults, this: :is_ignored } }
      let(:subject_defaults) { { subject: :defaults, this: :is_not_there_either } }
      let(:parent) { MagicLamp::DefaultsManager.new(configuration, parent_defaults) }
      subject { MagicLamp::DefaultsManager.new(configuration, subject_defaults, parent) }
      let(:expected_options) { { this: :is_there, subject: :defaults, parent: :defaults, extend: [] } }

      it "passes the block and the given options (merged with defaults) through" do
        expect(MagicLamp).to receive(:register_fixture) do |options, &passed_block|
          expect(options).to eq(expected_options)
          expect(passed_block).to eq(block)
        end
        subject.register_fixture(given_options, &block)
      end

      it "does not require options to be passed in" do
        expect do
          subject.register_fixture { render :foo }
        end.to_not raise_error
      end
    end
  end
end
