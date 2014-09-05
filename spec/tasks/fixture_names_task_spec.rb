require "spec_helper"

describe "Fixture names task" do
  it "outputs a sorted list of all the fixture names" do
    dummy = Object.new
    task_proc = Rake::Task["magic_lamp:fixture_names"].actions.first

    expect(dummy).to receive(:puts) do |output|
      fixture_names = MagicLamp.registered_fixtures.keys.sort
      expect(output).to_not be_empty
      expect(output).to eq(fixture_names)
    end

    dummy.instance_eval(&task_proc)
  end
end
