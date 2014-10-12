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
end
