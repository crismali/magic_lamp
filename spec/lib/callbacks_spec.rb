require "rails_helper"

describe MagicLamp::Callbacks do
  class DummyObject
    include MagicLamp::Callbacks
  end

  subject { DummyObject.new(MagicLamp::Configuration.new) }

  context "attr_accessor" do
    it { is_expected.to respond_to(:configuration) }
    it { is_expected.to respond_to(:configuration=) }
  end

  describe "#initialize" do
    it "sets configuration to the given argument" do
      configuration = double
      subject = DummyObject.new(configuration)
      expect(subject.configuration).to eq(configuration)
    end
  end

  describe "#execute_before_each_callback" do
    it "calls the before each callback" do
      dummy = double
      expect(dummy).to receive(:call)
      subject.configuration.before_each_proc = dummy
      subject.execute_before_each_callback
    end

    context "no callback" do
      it "does not raise an error" do
        subject.configuration.before_each_proc = nil
        expect do
          subject.execute_before_each_callback
        end.to_not raise_error
      end
    end
  end

  describe "#execute_after_each_callback" do
    it "calls the after each callback" do
      dummy = double
      expect(dummy).to receive(:call)
      subject.configuration.after_each_proc = dummy
      subject.execute_after_each_callback
    end

    context "no callback" do
      it "does not raise an error" do
        subject.configuration.after_each_proc = nil
        expect do
          subject.execute_after_each_callback
        end.to_not raise_error
      end
    end
  end
end
