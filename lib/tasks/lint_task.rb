namespace :magic_lamp do
  desc "Generates all Magic Lamp fixtures for debugging"
  task lint: :environment do
    puts "Linting Magic Lamp fixtures..."
    MagicLamp.generate_all_fixtures
    puts "Lookin' good!"
  end
end
