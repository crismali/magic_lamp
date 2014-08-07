require "rails_helper"

describe RenderCatcher do

  context "attr_accessor" do
    it { should respond_to :render_arguments }
    it { should respond_to :render_arguments= }
  end

  describe "#render" do
    it "saves its arguments as render arguments" do
      subject.render :foo, :bar, :baz
      expect(subject.render_arguments).to eq([:foo, :bar, :baz])
    end
  end

  describe "#catch_render_arguments" do
    let(:block) { Proc.new { render :foo, :bar, :baz } }
    let(:result) { subject.catch_render_arguments(&block) }

    it "returns the arguments to render given a block" do
      expect(result).to eq([:foo, :bar, :baz])
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
