# frozen_string_literal: false

require "rails_helper"

module CatchOutput
  def capture_stdout
    old_stdout = $stdout
    $stdout = StringIO.new("", "w")
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end
end

describe "magic_lamp:lint" do
  it do
    is_expected.to depend_on(
      "magic_lamp:lint:config",
      "magic_lamp:lint:files",
      "magic_lamp:lint:fixtures"
    )
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

    it "does not abort" do
      expect(MagicLamp::Genie.instance).to_not receive(:abort)
    end
  end

  context "errors" do
    let!(:error_proc) { proc { raise "Nope" } }

    before do
      allow(MagicLamp::Genie.instance).to receive(:abort)
    end

    it "tells us if the file could be loaded" do
      allow(MagicLamp).to receive(:load_config) do
        load Rails.root.join("error_specs", "config_file_load_error.rb")
      end
      expect(output).to match("Linting Magic Lamp configuration")
      expect(output).to_not match("Configuration looks good")
      expect(output).to match("Loading configuration failed")
      expect(output).to match("RuntimeError: Nope")
    end

    %i[before after].each do |callback_type|
      it "tells us if the #{callback_type}_each callback is broken" do
        expect_any_instance_of(MagicLamp::Configuration).to receive("#{callback_type}_each_proc").and_return(error_proc)

        expect(output).to match("Linting Magic Lamp configuration")
        expect(output).to_not match("Configuration looks good")
        expect(output).to match("Executing #{callback_type}_each failed with:")
        expect(output).to match("RuntimeError: Nope")
      end
    end

    it "aborts the task" do
      allow(MagicLamp).to receive(:load_config) do
        load Rails.root.join("error_specs", "config_file_load_error.rb")
      end
      expect(MagicLamp::Genie.instance).to receive(:abort)
      capture_stdout { subject.execute }
    end
  end
end

describe "magic_lamp:lint:files" do
  include CatchOutput
  let(:output) { capture_stdout { subject.execute } }

  before do
    allow(MagicLamp::Genie.instance).to receive(:abort).and_return(:abort)
  end

  it { is_expected.to depend_on(:environment) }

  context "no errors" do
    it "tells us everything is fine" do
      expect(output).to match("Linting lamp files")
      expect(output).to match("Lamp files look good")
    end

    it "does not abort" do
      expect(MagicLamp::Genie.instance).to_not receive(:abort)
      capture_stdout { subject.execute }
    end
  end

  context "errors" do
    let!(:lamp_file_paths) do
      ["first_errored_lamp_file.rb", "second_errored_lamp_file.rb"].map do |file_name|
        Rails.root.join("error_specs", file_name).to_s
      end
    end

    it "tells us which files are broken and how" do
      first_error_file_path, second_error_file_path = lamp_file_paths
      allow(MagicLamp).to receive(:lamp_files).and_return(lamp_file_paths)

      expect(output).to match("Linting lamp files")
      expect(output).to_not match("Lamp files look good")

      expect(output).to match(first_error_file_path)
      expect(output).to match(second_error_file_path)
      expect(output).to match("RuntimeError: first file")
      expect(output).to match("RuntimeError: second file")
    end

    it "aborts the task" do
      allow(MagicLamp).to receive(:lamp_files).and_return(lamp_file_paths)
      expect(MagicLamp::Genie.instance).to receive(:abort)
      capture_stdout { subject.execute }
    end
  end
end

describe "magic_lamp:lint:fixtures" do
  include CatchOutput
  let(:output) { capture_stdout { subject.execute } }

  it { is_expected.to depend_on(:environment) }

  context "no errors" do
    it "lets us know the fixtures are good" do
      expect(output).to match("Linting Magic Lamp fixtures")
      expect(output).to match("Fixtures look good")
    end

    it "does not abort" do
      expect(MagicLamp::Genie.instance).to_not receive(:abort)
      capture_stdout { subject.execute }
    end
  end

  context "errors" do
    before do
      allow(MagicLamp::Genie.instance).to receive(:abort).and_return(:abort)
      allow(MagicLamp).to receive(:lamp_files).and_return([Rails.root.join("error_specs", "broken_fixtures.rb").to_s])
    end

    it "tells us which fixtures are broken" do
      expect(output).to match(/the following fixtures are broken/i)
      expect(output).to match(/Name: "foo"/)
      expect(output).to match(%r{Name: "orders\/bar"})
    end

    it "displays the file the fixture is in" do
      expect(output).to match(%r{File: .+\/broken_fixtures.rb:7})
      expect(output).to match(%r{File: .+\/broken_fixtures.rb:13})
    end

    it "displays the broken fixture's code" do
      expect(output).to match("fixture\\(name: ")
    end

    it "displays the extensions" do
      expect(output).to match("Extensions: None")
      expect(output).to match("Extensions: SomeExtension, OtherExtension")
    end

    it "displays the controller" do
      expect(output).to match("Controller: ApplicationController")
      expect(output).to match("Controller: OrdersController")
    end

    it "displays the error" do
      expect(output).to match("RuntimeError: first fixture")
      expect(output).to match("RuntimeError: second fixture")
    end

    it "aborts the task" do
      expect(MagicLamp::Genie.instance).to receive(:abort)
      capture_stdout { subject.execute }
    end
  end
end

describe "mll" do
  it "is an alias for magic_lamp:lint" do
    expect(subject).to depend_on("magic_lamp:lint")
  end
end
