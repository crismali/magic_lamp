require "rails_helper"

describe "magic_lamp:fixture_names" do
  it { is_expected.to depend_on(:environment) }

  it "outputs a sorted list of all the fixture names" do
    expect(MAIN_OBJECT).to receive(:puts) do |output|
      fixture_names = MagicLamp.registered_fixtures.keys.sort
      expect(output).to_not be_empty
      expect(output).to eq(fixture_names)
    end

    subject.execute
  end
end

describe "mlfn" do
  it "is an alias for magic_lamp:fixture_names" do
    expect(subject).to depend_on("magic_lamp:fixture_names")
  end
end
