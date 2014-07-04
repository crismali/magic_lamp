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
end

desc "Creates fixtures from MagicLamp files"
task magic_lamp: "magic_lamp:create_fixtures"
