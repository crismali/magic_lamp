require "rails_helper"


describe MagicLamp::Helpers do
  class DummyObject
    include MagicLamp::Helpers
  end

  subject { DummyObject.new }

  describe "#namespace" do
    it "is MagicLamp" do
      expect(subject.namespace).to eq(MagicLamp)
    end
  end

  describe "#execute_before_each_callback" do
    it "calls the before each callback" do
      dummy = double
      expect(dummy).to receive(:call)
      subject.namespace.before_each_proc = dummy
      subject.execute_before_each_callback
    end

    context "no callback" do
      it "does not raise an error" do
        subject.namespace.before_each_proc = nil
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
      subject.namespace.after_each_proc = dummy
      subject.execute_after_each_callback
    end

    context "no callback" do
      it "does not raise an error" do
        subject.namespace.after_each_proc = nil
        expect do
          subject.execute_after_each_callback
        end.to_not raise_error
      end
    end
  end
end
