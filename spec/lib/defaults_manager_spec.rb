require "rails_helper"

describe MagicLamp::DefaultsManager do
  subject { MagicLamp::DefaultsManager.new(MagicLamp::Configuration.new, {}) }

  context "attr_accessor" do
    it { is_expected.to attr_accessorize(:configuration) }
    it { is_expected.to attr_accessorize(:parent) }
    it { is_expected.to attr_accessorize(:defaults) }
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
    subject { MagicLamp::DefaultsManager.new(configuration, subject_defaults, parent) }
    let(:actual) { subject.all_defaults }
    let(:expected_defaults) { [global_defaults, grandparent_defaults, parent_defaults, subject_defaults] }

    it "returns the global defaults, all parent defaults, and the manager's defaults" do
      expect(actual).to match_array(expected_defaults)
      expect(actual).to eq(expected_defaults)
    end
  end

  describe "#merge_with_defaults" do
    let(:global_defaults) { { global: :defaults } }
    let(:grandparent_defaults) { { grandparent: :defaults, that: :is_ignored } }
    let(:parent_defaults) { { parent: :defaults, this: :is_ignored } }
    let(:subject_defaults) { { subject: :defaults, this: :is_there } }
    let(:configuration) { MagicLamp::Configuration.new.tap { |config| config.global_defaults = global_defaults } }
    let(:grandparent) { MagicLamp::DefaultsManager.new(configuration, grandparent_defaults) }
    let(:parent) { MagicLamp::DefaultsManager.new(configuration, parent_defaults, grandparent) }
    subject { MagicLamp::DefaultsManager.new(configuration, subject_defaults, parent) }
    let(:actual) { subject.merge_with_defaults(that: :is_there) }
    let(:expected_defaults) do
      {
        global: :defaults,
        grandparent: :defaults,
        parent: :defaults,
        subject: :defaults,
        this: :is_there,
        that: :is_there
      }
    end

    it "merges all of the branch's defaults into one hash where the children take precedence" do
      expect(actual).to eq(expected_defaults)
    end
  end

  describe "#define" do
    let(:new_defaults) { { very_new: :defaults } }

    it "creates a new defaults manager, passes it to the block" do
      suspect = nil
      subject.define(new_defaults) do |block_suspect|
        suspect = block_suspect
      end
      expect(suspect).to be_a(MagicLamp::DefaultsManager)
      expect(suspect).to_not eq(subject)
      expect(suspect.defaults).to eq(new_defaults)
      expect(suspect.configuration).to eq(subject.configuration)
      expect(suspect.parent).to eq(subject)
    end

    it "raises an error if called without a block" do
      expect do
        subject.define(foo: :bar)
      end.to raise_error(MagicLamp::ArgumentError, "`define` requires a block")
    end
  end
end
