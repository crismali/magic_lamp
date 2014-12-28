require "method_source"

namespace :magic_lamp do
  desc "Generates all Magic Lamp fixtures and displays errors for debugging"
  task lint: :environment do
    file_errors, fixture_errors = MagicLamp.lint_fixtures.values_at(:files, :fixtures)
    template = File.read("#{File.dirname(__FILE__)}/lint_template.erb")
    erb_template = ERB.new(template)
    puts erb_template.result(binding)
  end

  namespace :lint do

    desc "Lints your Magic Lamp configuration and reports any errors"
    task config: :environment do
      puts "Linting Magic Lamp configuration..."
      errors = MagicLamp.lint_config
      if errors.present?
        if errors[:config_file_load].present?
          puts "Loading configuration failed with:"
          puts "\n#{errors[:config_file_load]}"
        end

        [:before_each, :after_each].each do |callback|
          if errors[callback].present?
            puts "Executing #{callback} failed with:"
            puts "\n#{errors[callback]}"
          end
        end

      else
        puts "Configuration looks good!"
      end
    end

  end
end

desc "Generates all Magic Lamp fixtures and displays errors for debugging (alias for `magic_lamp:lint`)"
task mll: "magic_lamp:lint"
