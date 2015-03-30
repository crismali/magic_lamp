MagicLamp::Genie.rake_tasks do
  namespace :magic_lamp do
    desc "Displays all Magic Lamp fixture names"
    task fixture_names: :environment do
      MagicLamp.load_lamp_files
      puts MagicLamp.registered_fixtures.keys.sort
    end
  end

  desc "Displays all Magic Lamp fixture names (alias for `magic_lamp:fixture_names`)"
  task mlfn: "magic_lamp:fixture_names"
end
