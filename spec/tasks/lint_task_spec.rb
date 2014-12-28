require "rails_helper"

module CatchOutput
  def capture_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new("", "w")
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end
end

describe "magic_lamp:lint" do
  let!(:output) { [] }
  let(:outputs) { output.join("\n") }

  before do
    allow(MAIN_OBJECT).to receive(:puts) do |text|
      output << text
    end
  end

  it { is_expected.to depend_on(:environment) }

  context "no errors" do
    it "tells us everything looks good" do
      subject.execute

      expect(outputs).to match(/linting[\w\s]+fixtures/i)
      expect(outputs).to match(/lookin' good/i)
    end
  end

  context "errors" do
    it "outputs all broken files and their errors" do
      lamp_file_paths = ["first_errored_lamp_file.rb", "second_errored_lamp_file.rb"].map do |file_name|
        Rails.root.join("error_specs", file_name).to_s
      end
      first_error_file_path, second_error_file_path = lamp_file_paths
      allow(MagicLamp).to receive(:lamp_files).and_return(lamp_file_paths)

      subject.execute

      expect(outputs).to match(/linting[\w\s]+fixtures/i)
      expect(outputs).to_not match(/lookin' good/i)

      expect(outputs).to match(/files could not be loaded/)
      expect(outputs).to match(first_error_file_path)
      expect(outputs).to match(second_error_file_path)

      expect(outputs).to match(/RuntimeError: first/)
      expect(outputs).to match(/RuntimeError: second/)
    end

    it "outputs the broken fixture names and errors" do
      allow(MagicLamp).to receive(:lamp_files).and_return([Rails.root.join("error_specs", "broken_fixtures.rb").to_s])
      subject.execute

      expect(outputs).to match(/the following fixtures are broken/i)
      expect(outputs).to match(/"foo" in .+broken_fixtures.rb on line 1/i)
      expect(outputs).to match(/"orders\/bar" in .+broken_fixtures.rb on line 7/i)
      expect(outputs).to match(/raise "first fixture"/i)
      expect(outputs).to match(/raise "second fixture"/i)
      expect(outputs).to match(/RuntimeError: first fixture/i)
      expect(outputs).to match(/RuntimeError: second fixture/i)
      expect(outputs).to match(/extensions:/i)
      expect(outputs).to match(/controller: applicationcontroller/i)
    end
  end
end

describe "magic_lamp:lint:config" do
  include CatchOutput
  let(:output) { capture_stdout { subject.execute } }

  it { is_expected.to depend_on(:environment) }

  context "no errors" do
    it "tells us that everything looks good" do
      expect(output).to match("Linting Magic Lamp configuration")
      expect(output).to match("Configuration looks good")
    end
  end

  context "errors" do
    it "tells us if the file could be loaded" do
      allow(MagicLamp).to receive(:load_config) do
        load Rails.root.join("error_specs", "config_file_load_error.rb")
      end
      expect(output).to match("Linting Magic Lamp configuration")
      expect(output).to_not match("Configuration looks good")
      expect(output).to match("Loading configuration failed")
      expect(output).to match("RuntimeError: Nope")
    end

    [:before, :after].each do |callback_type|
      it "tells us if the #{callback_type}_each callback is broken" do
        MagicLamp.configuration.send("#{callback_type}_each") do
          raise "Nope"
        end

        expect(output).to match("Linting Magic Lamp configuration")
        expect(output).to_not match("Configuration looks good")
        expect(output).to match("Executing #{callback_type}_each failed with:")
        expect(output).to match("RuntimeError: Nope")
      end
    end
  end
end

describe "mll" do
  it "is an alias for magic_lamp:lint" do
    expect(subject).to depend_on("magic_lamp:lint")
  end
end
