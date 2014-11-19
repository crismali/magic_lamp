require "rails_helper"

describe "magic_lamp:lint" do
  it { is_expected.to depend_on(:environment) }

  it "generates all fixtures" do
    expect(MagicLamp).to receive(:generate_all_fixtures)
    allow(MAIN_OBJECT).to receive(:puts).and_return(:puts)
    subject.execute
  end
end

describe "mll" do
  it "is an alias for magic_lamp:lint" do
    expect(subject).to depend_on("magic_lamp:lint")
  end
end
