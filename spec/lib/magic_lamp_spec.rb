require "rails_helper"

describe MagicLamp do

  describe "#path" do
    context "spec directory" do
      let(:spec_path) { Rails.root.join("spec") }

      it "returns a default path starting from spec" do
        expect(subject.path).to eq(spec_path)
      end
    end

    context "no spec directory" do
      let(:test_path) { Rails.root.join("test") }

      it "returns a default path starting from test" do
        allow(Dir).to receive(:exist?).and_return(false)
        expect(subject.path).to eq(test_path)
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

  describe "#create_fixture" do

    it "passes through its arguments and block to an instance of FixtureCreator" do
      passed_block = Proc.new { render :foo }
      fixture_creator = MagicLamp::FixtureCreator.new
      allow(MagicLamp::FixtureCreator).to receive(:new).and_return(fixture_creator)

      expect(fixture_creator).to receive(:create_fixture) do |fixture_name, controller_class, &block|
        expect(fixture_name).to eq("foo")
        expect(controller_class).to eq(OrdersController)
        expect(block).to eq(passed_block)
      end

      subject.create_fixture("foo", OrdersController, &passed_block)
    end
  end

  describe "#load_lamp_files" do

    it "calls create_tmp_directory" do
      expect(subject).to receive(:create_tmp_directory).and_call_original
      subject.load_lamp_files
    end

    it "loads all _lamp files in the specified path" do
      subject.load_lamp_files
      expect(subject.instance_eval("@foo")).to eq("from lamp file")
    end
  end
end
