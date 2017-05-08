# frozen_string_literal: true

require "rails_helper"

describe MagicLamp::Configuration do
  context "attr_accessor" do
    it { is_expected.to attr_accessorize :before_each_proc }
    it { is_expected.to attr_accessorize :after_each_proc }
    it { is_expected.to attr_accessorize :infer_names }
    it { is_expected.to attr_accessorize :global_defaults }
  end

  describe "#initialize" do
    it "infers names by default" do
      expect(subject.infer_names).to eq(true)
    end

    it "has an empty hash for global defaults" do
      expect(subject.global_defaults).to eq({})
    end
  end

  describe "#before_each" do
    it "saves its given block" do
      block = proc { "something before" }
      subject.before_each(&block)
      expect(subject.before_each_proc).to eq(block)
    end

    it "raises an error when not given a block" do
      expect do
        subject.before_each
      end.to raise_error(MagicLamp::ArgumentError, /configuration#before_each requires a block/)
    end
  end

  describe "#after_each" do
    it "saves its given block" do
      block = proc { "something before" }
      subject.after_each(&block)
      expect(subject.after_each_proc).to eq(block)
    end

    it "raises an error when not given a block" do
      expect do
        subject.after_each
      end.to raise_error(MagicLamp::ArgumentError, /configuration#after_each requires a block/)
    end
  end
end
