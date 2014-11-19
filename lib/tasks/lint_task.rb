namespace :magic_lamp do
  desc "Generates all Magic Lamp fixtures for debugging"
  task lint: :environment do
    puts "\n\nLinting Magic Lamp fixtures...\n"
    MagicLamp.generate_all_fixtures
    puts "Lookin' good!\n\n\n"
  end
end

desc "Generates all Magic Lamp fixtures for debugging (alias for `magic_lamp:lint`)"
task mll: "magic_lamp:lint"
