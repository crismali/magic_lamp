MagicLamp::Genie.rake_tasks do
  namespace :magic_lamp do
    namespace :konacha do
      redraw_konacha_routes = proc do
        Konacha::Engine.routes.draw do
          mount MagicLamp::Genie, at: "/magic_lamp"
          get "/iframe/*name" => "specs#iframe", format: false, as: :iframe
          root to: "specs#parent"
          get "*path" => "specs#parent", format: false
        end
      end

      desc "Run Konacha JavaScript specs interactively with MagicLamp"
      task serve: :environment do
        redraw_konacha_routes.call
        Konacha.serve
      end

      desc "Run Konacha JavaScript specs non-interactively with MagicLamp"
      task run: :environment do
        redraw_konacha_routes.call
        passed = Konacha.run
        exit 1 unless passed
      end
    end
  end

  task mlks: "magic_lamp:konacha:serve"
  task mlkr: "magic_lamp:konacha:run"
end
