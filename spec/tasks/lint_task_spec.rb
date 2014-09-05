require "spec_helper"

describe "Lint task" do
  it "generates all fixtures" do
    expect(MagicLamp).to receive(:generate_all_fixtures)
    dummy = double(puts: nil)
    task_proc = Rake::Task["magic_lamp:lint"].actions.first
    dummy.instance_eval(&task_proc)
  end
end
