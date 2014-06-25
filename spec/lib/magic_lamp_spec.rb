require "rails_helper"
require "fileutils"

describe MagicLamp do
  before do
    FileUtils.rm_rf(Rails.root.join("tmp/magic_lamp"))
  end

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

  describe "#create_tmp_directory" do
    let(:tmp_directory) { subject.tmp_path }

    before do
      subject.create_tmp_directory
    end

    it "creates the magic lamp tmp directory" do
      expect(File.exist?(tmp_directory)).to eq(true)
    end

    it "doesn't throw an error when the directory already exists" do
      expect do
        subject.create_tmp_directory
      end.to_not raise_error
    end
  end

  describe "#remove_tmp_directory" do
    let(:tmp_directory) { subject.tmp_path }

    before do
      subject.create_tmp_directory
      subject.remove_tmp_directory
    end

    it "removes the magic lamp tmp directory" do
      expect(File.exist?(tmp_directory)).to eq(false)
    end

    it "doesn't throw an error when the directory doesn't exist before deletion" do
      expect do
        subject.remove_tmp_directory
      end.to_not raise_error
    end
  end
end
