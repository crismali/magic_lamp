require "rails_helper"

describe MagicLamp do

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
end
