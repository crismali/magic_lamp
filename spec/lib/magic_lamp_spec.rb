require "rails_helper"

describe MagicLamp do

  context "attr_writer" do
    context "path" do
      it { should respond_to :path= }
    end
  end

  describe "#path" do
    context "spec directory" do
      let(:spec_path) { Rails.root.join("spec/magic_lamp") }

      it "returns a default path starting from spec" do
        expect(subject.path).to eq(spec_path)
      end
    end

    context "no spec directory" do
      let(:test_path) { Rails.root.join("test/magic_lamp") }

      it "returns a default path starting from test" do
        allow(Dir).to receive(:exist?).and_return(false)
        expect(subject.path).to eq(test_path)
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

  describe "#default_path" do

    it "returns the path to spec/magic_lamp" do
      expect(subject.default_path).to eq(["spec", "magic_lamp"])
    end

    context "no spec directory" do
      it "returns the path to test/magic_lamp" do
        allow(Dir).to receive(:exist?).and_return(false)
        expect(subject.default_path).to eq(["test", "magic_lamp"])
      end
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

  describe "#clear_fixtures" do

    it "clears the fixtures (by calling through to a fixture creator instance" do
      fixture_creator = MagicLamp::FixtureCreator.new
      allow(MagicLamp::FixtureCreator).to receive(:new).and_return(fixture_creator)

      expect(fixture_creator).to receive(:remove_tmp_directory)

      MagicLamp.clear_fixtures
    end
  end

  describe "#load_config" do
    it "requires the magic lamp config file" do
      subject.load_config
      expect(subject.instance_eval("@path")).to eq("foomaster")
    end

    context "test directory" do
      it "requires the config file from the test directory when there's no spec directory" do
        allow(Dir).to receive(:exist?).and_return(false)
        subject.load_config
        expect(subject.instance_eval("@path")).to eq("footestmaster")
      end
    end
  end

  describe "#load_lamp_files" do

    it "loads all _lamp files in the specified path" do
      subject.load_lamp_files
      expect(subject.instance_eval("@path")).to eq("from lamp file")
    end
  end
end
