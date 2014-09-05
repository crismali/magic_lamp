namespace :magic_lamp do
  desc "Displays all Magic Lamp fixture names"
  task fixture_names: :environment do
    MagicLamp.load_lamp_files
    puts MagicLamp.registered_fixtures.keys.sort
  end
end
