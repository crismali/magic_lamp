require "rails_helper"

describe RenderCatcher do

  context "attr_accessor" do
    it { should respond_to :render_argument }
    it { should respond_to :render_argument= }
  end

  describe "#render" do
    it "saves its first arguments as render argument" do
      subject.render :foo, :bar, :baz
      expect(subject.render_argument).to eq(:foo)
    end
  end

  describe "#first_render_argument" do
    let(:block) { Proc.new { render :foo, :bar, :baz } }
    let(:result) { subject.first_render_argument(&block) }

    it "returns the first argument to render given a block" do
      expect(result).to eq(:foo)
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
