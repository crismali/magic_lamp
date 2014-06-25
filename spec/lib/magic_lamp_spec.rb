require "rails_helper"

describe MagicLamp do
  context "attr_writer" do
    it "has path=" do
      expect(subject).to respond_to(:path=)
    end
  end

  describe "#path" do
    after do
      subject.path = nil
    end

    context "spec directory" do
      let(:spec_path) { Rails.root.join("spec/magic_lamp") }

      it "returns a default path starting from spec" do
        expect(subject.path).to eq(spec_path)
      end
    end

    context "specified" do
      let(:specified_path) { Rails.root.join("foo") }

      before do
        subject.path = "foo"
      end

      it "returns the specified path relative to Rails root" do
        expect(subject.path).to eq(specified_path)
      end
    end
  end

  describe "#tmp_path" do
    let(:tmp_path) { Rails.root.join("tmp/magic_lamp") }

    it "returns the path to tmp" do
      expect(subject.tmp_path).to eq(tmp_path)
    end
  end
end
