require "rails_helper"

describe "Integration", integration: true do
  let(:rake_test_path) { Rails.root.join("tmp/magic_lamp/rake_test.html") }
  let(:magic_lamp_test_path) { Rails.root.join("tmp/magic_lamp/via_magic_lamp_file.html") }

  it "creates fixture files from lamp files" do
    Dir.chdir(Rails.root) do
      system "rake db:drop"
      system "rake db:create"
      system "rake db:migrate"
      system "rake magic_lamp"
    end

    expect(File.exist?(rake_test_path)).to eq(true)
    expect(File.read(rake_test_path)).to eq("foo\n")

    expect(File.exist?(magic_lamp_test_path)).to eq(true)
    expect(File.read(magic_lamp_test_path)).to match("<h1>New order</h1>")
  end
end
