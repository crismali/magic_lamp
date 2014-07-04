require "rails_helper"

describe MagicLamp do

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

  describe "#load_lamp_files" do

    it "loads all _lamp files in the specified path" do
      subject.load_lamp_files
      expect(subject.instance_eval("@path")).to eq("from lamp file")
    end
  end
end
