require "spec_helper"

describe "Lint task" do
  it "generates all fixtures" do
    expect(MagicLamp).to receive(:generate_all_fixtures)
    Rake::Task["magic_lamp:lint"].invoke
  end
end
