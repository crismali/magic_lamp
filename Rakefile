begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

# Dummy App
# -----------------------------------------------------------------------------
APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load "rails/tasks/engine.rake"

require "rspec/core/rake_task"
desc "run rspec specs"
RSpec::Core::RakeTask.new(:spec) do |t|
end

desc "Run the javascript specs"
task teaspoon: "app:teaspoon"

namespace :spec do
  desc "runs integration tests only"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = "spec/integration/**/*_spec.rb"
    t.rspec_opts = "--tag integration"
  end

  desc "Run both test suites"
  task all: %w(spec teaspoon)
end

task default: ["spec:all"]

Bundler::GemHelper.install_tasks
