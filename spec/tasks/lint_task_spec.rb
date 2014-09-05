require "rails_helper"

describe "Lint task" do
  let(:task) { Rake::Task["magic_lamp:lint"] }

  it "generates all fixtures" do
    expect(MagicLamp).to receive(:generate_all_fixtures)
    dummy = double(puts: nil)
    task_proc = task.actions.first
    dummy.instance_eval(&task_proc)
  end

  it "depends on the environment task" do
    prereqs = task.all_prerequisite_tasks
    expect(prereqs).to include(Rake::Task["environment"])
  end
end
