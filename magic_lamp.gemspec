$LOAD_PATH.push File.expand_path("../lib", __FILE__)

require "magic_lamp/version"

Gem::Specification.new do |s|
  s.name        = "magic_lamp"
  s.version     = MagicLamp::VERSION
  s.authors     = ["Michael Crismali"]
  s.email       = ["michael.crismali@gmail.com"]
  s.homepage    = "https://github.com/crismali/magic_lamp"
  s.summary     = "Makes sure your JavaScript tests break when if your templates change."
  s.description = "MagicLamp provides an easy way to get your Rails templates into your JavaScript specs."
  s.license     = "Apache"

  s.files = Dir["{app,config,lib}/**/*", "VERSION", "LICENSE", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.0"
  s.add_dependency "rake"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "selenium-webdriver"
  s.add_development_dependency "teaspoon"
  s.add_development_dependency "dotenv-rails"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "fantaskspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-nav"
  s.add_development_dependency "pry-doc"
  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "database_cleaner"
end
