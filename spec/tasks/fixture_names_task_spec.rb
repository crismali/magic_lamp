require "rails_helper"

describe "Fixture names task" do
  let(:task) { Rake::Task["magic_lamp:fixture_names"] }

  it "outputs a sorted list of all the fixture names" do
    dummy = Object.new
    task_proc = task.actions.first

    expect(dummy).to receive(:puts) do |output|
      fixture_names = MagicLamp.registered_fixtures.keys.sort
      expect(output).to_not be_empty
      expect(output).to eq(fixture_names)
    end

    dummy.instance_eval(&task_proc)
  end

  it "depends on the environment task" do
    prereqs = task.all_prerequisite_tasks
    expect(prereqs).to include(Rake::Task["environment"])
  end
end
