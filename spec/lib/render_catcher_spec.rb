require "rails_helper"

describe MagicLamp::RenderCatcher do
  subject { MagicLamp::RenderCatcher.new(MagicLamp::Configuration.new) }

  it_behaves_like "it has callbacks"

  context "attr_accessor" do
    it { is_expected.to attr_accessorize :render_argument }
  end

  describe "#render" do
    it "saves its first arguments as render argument" do
      subject.render :foo, :bar, :baz
      expect(subject.render_argument).to eq(:foo)
    end
  end

  describe "#first_render_argument" do
    it "returns the first argument to render given a block" do
      result = subject.first_render_argument { render :foo, :bar, :baz }
      expect(result).to eq(:foo)
    end

    it "executes callbacks around the evaluation of the block" do
      expect(subject).to receive(:execute_callbacks_around).and_call_original
      subject.first_render_argument { render :foo }
      expect(subject.render_argument).to eq(:foo)
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

    it "returns itself" do
      expect(subject.foo.bar.baz).to eq(subject)
    end
  end
end
