require "rake"

namespace :magic_lamp do
  desc "Remove MagicLamp fixtures"
  task clean: :environment do
    MagicLamp.remove_tmp_directory
  end

  desc "Creates fixtures from MagicLamp files"
  task create_fixtures: :clean do
    MagicLamp.load_lamp_files
  end

  # Test runner integration tasks

  desc "Create fixtures and run Teaspoon specs"
  task teaspoon: :create_fixtures do
    Rake::Task["teaspoon"].invoke
  end

  desc "Create fixtures and run Jasmine Rails specs"
  task jasmine: :create_fixtures do
    Rake::Task["spec:javascript"].invoke
  end

  desc "Create fixtures and run Evergreen specs"
  task evergreen: :create_fixtures do
    Rake::Task["spec:javascripts"].invoke
  end

  desc "Create fixtures and run Konacha specs"
  task konacha: :create_fixtures do
    Rake::Task["konacha:run"].invoke
  end
end

# Alias for magic_lamp:create_fixtures
desc "Creates fixtures from MagicLamp files"
task magic_lamp: "magic_lamp:create_fixtures"
