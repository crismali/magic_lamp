require "rails_helper"

describe MagicLamp::RenderCatcher do

  it { is_expected.to be_kind_of(MagicLamp::Callbacks) }

  context "attr_accessor" do
    it { is_expected.to respond_to :render_argument }
    it { is_expected.to respond_to :render_argument= }
  end

  describe "#render" do
    it "saves its first arguments as render argument" do
      subject.render :foo, :bar, :baz
      expect(subject.render_argument).to eq(:foo)
    end
  end

  describe "#first_render_argument" do
    let(:block) { proc { render :foo, :bar, :baz } }
    let(:result) { subject.first_render_argument(&block) }

    it "returns the first argument to render given a block" do
      expect(result).to eq(:foo)
    end

    it "executes callbacks around the evaluation of the block" do
      expect(subject).to receive(:execute_before_each_callback).ordered
      expect(subject).to receive(:instance_eval).ordered
      expect(subject).to receive(:execute_after_each_callback).ordered
      subject.first_render_argument { render :foo }
    end
  end

  describe "#method_missing" do
    it "does nothing when an unknown method is called" do
      expect do
        subject.foo
        subject.foo = "what"
        subject.bar(1, 2, 3) { |x| "never gonna happen" }
      end.to_not raise_error
    end
  end
end
