# frozen_string_literal: true

MagicLamp::Genie.rake_tasks do
  namespace :magic_lamp do
    desc "Generates all Magic Lamp fixtures and displays errors for debugging"
    task lint: ["magic_lamp:lint:config", "magic_lamp:lint:files", "magic_lamp:lint:fixtures"]

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

          %i[before_each after_each].each do |callback|
            if errors[callback].present?
              puts "Executing #{callback} failed with:"
              puts "\n#{errors[callback]}"
            end
          end
          abort
        else
          puts "Configuration looks good!"
        end
      end

      desc "Lints your Magic Lamp lamp files and reports any errors"
      task files: :environment do
        puts "Linting lamp files..."
        errors = MagicLamp.lint_fixtures[:files]

        if errors.present?
          puts "The following files are broken:"
          puts ""

          errors.each do |path, error|
            puts "File: #{path}"
            puts "Error: #{error}"
            puts ""
          end
          abort
        else
          puts "Lamp files look good!"
        end
      end

      desc "Lints your Magic Lamp fixtures and reports any errors"
      task fixtures: :environment do
        puts "Linting Magic Lamp fixtures..."
        errors = MagicLamp.lint_fixtures[:fixtures]

        if errors.present?
          puts "The following fixtures are broken:"
          puts ""

          errors.each do |name, fixture_info|
            puts "Name: \"#{name}\""
            render_block = fixture_info[:render_block]
            puts "File: #{render_block.source_location.join(':')}"
            puts "Controller: #{fixture_info[:controller]}"

            extensions = if fixture_info[:extend].present?
                           fixture_info[:extend].join(", ")
                         else
                           "None"
                         end

            puts "Extensions: #{extensions}"
            puts ""
            puts "Source code:"
            puts render_block.source
            puts ""
            puts "Error: #{fixture_info[:error]}"
            puts ""
          end
          abort
        else
          puts "Fixtures look good!"
        end
      end
    end
  end

  desc "Generates all Magic Lamp fixtures and displays errors for debugging (alias for `magic_lamp:lint`)"
  task mll: "magic_lamp:lint"
end
