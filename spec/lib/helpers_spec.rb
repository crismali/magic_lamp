require "rails_helper"


describe MagicLamp::Callbacks do
  class DummyObject
    include MagicLamp::Callbacks
  end

  subject { DummyObject.new }

  describe "#execute_before_each_callback" do
    it "calls the before each callback" do
      dummy = double
      expect(dummy).to receive(:call)
      MagicLamp.before_each_proc = dummy
      subject.execute_before_each_callback
    end

    context "no callback" do
      it "does not raise an error" do
        MagicLamp.before_each_proc = nil
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
      MagicLamp.after_each_proc = dummy
      subject.execute_after_each_callback
    end

    context "no callback" do
      it "does not raise an error" do
        MagicLamp.after_each_proc = nil
        expect do
          subject.execute_after_each_callback
        end.to_not raise_error
      end
    end
  end
end
