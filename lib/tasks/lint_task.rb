require "method_source"

namespace :magic_lamp do
  desc "Generates all Magic Lamp fixtures for debugging"
  task lint: :environment do
    file_errors, fixture_errors = MagicLamp.lint_fixtures.values_at(:files, :fixtures)
    template = File.read("#{File.dirname(__FILE__)}/lint_template.erb")
    erb_template = ERB.new(template)
    puts erb_template.result(binding)
  end
end

desc "Generates all Magic Lamp fixtures for debugging (alias for `magic_lamp:lint`)"
task mll: "magic_lamp:lint"
