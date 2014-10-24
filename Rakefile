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
  task :all do
    Rake::Task["spec"].invoke
    Rake::Task["teaspoon"].invoke
  end
end

task default: ["spec:all"]

Bundler::GemHelper.install_tasks

namespace :version do
  desc "Write the version via MAJOR, MINOR, and PATCH"
  task :write do
    File.write(File.join(Rake.original_dir, "VERSION"), [ENV["MAJOR"], ENV["MINOR"], ENV["PATCH"]].join("."))
  end

  namespace :bump do
    major, minor, patch = MagicLamp::VERSION.split(".").map(&:to_i)
    write_version = proc do
      File.write(File.join(Rake.original_dir, "VERSION"), [major, minor, patch].join("."))
    end

    desc "Bump major version"
    task :major do
      major += 1
      write_version.call
    end

    desc "Bump minor version"
    task :minor do
      minor += 1
      write_version.call
    end

    desc "Bump patch version"
    task :patch do
      patch += 1
      write_version.call
    end
  end
end
